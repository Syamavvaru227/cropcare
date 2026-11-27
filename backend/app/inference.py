"""Fail closed: training metadata, rather than guesses, controls inference."""
import json
import os
from pathlib import Path
import numpy as np

class Predictor:
    def __init__(self):
        self.model = None
        self.config = None
        self.reason = 'Model and verified training metadata are not configured.'
        model_path = Path(os.getenv('MODEL_PATH', 'models/crop_disease_model.keras'))
        config_path = Path(os.getenv('MODEL_CONFIG', 'models/model_config.json'))
        if not model_path.exists() or not config_path.exists():
            return
        try:
            config = json.loads(config_path.read_text())
            assert config['verified_from_training'] is True
            assert len(config['class_ids']) == 10 and len(set(config['class_ids'])) == 10
            known = {d['id'] for d in json.loads((Path(__file__).parent / 'data/diseases.json').read_text(encoding='utf-8'))}
            assert set(config['class_ids']) == known
            assert config['input_size'] == [224, 224]
            assert config['preprocessing'] in ['mobilenet_v2', 'zero_one', 'raw_0_255']
            assert config['resize'] in ['nearest', 'bilinear', 'bicubic']
            assert config['output'] in ['probabilities', 'logits']
            import tensorflow as tf
            self.model = tf.keras.models.load_model(model_path, compile=False)
            assert tuple(self.model.input_shape[1:]) == (224, 224, 3)
            assert self.model.output_shape[-1] == 10
            self.config = config
            self.reason = ''
        except Exception:
            self.model = None
            self.reason = 'Model or training metadata failed validation. Check server configuration.'

    def predict(self, image):
        from PIL import Image
        c = self.config
        interpolation = {'nearest': Image.Resampling.NEAREST, 'bilinear': Image.Resampling.BILINEAR, 'bicubic': Image.Resampling.BICUBIC}[c['resize']]
        x = np.asarray(image.resize((224, 224), interpolation), dtype=np.float32)
        if c['preprocessing'] == 'mobilenet_v2':
            x = x / 127.5 - 1
        elif c['preprocessing'] == 'zero_one':
            x /= 255
        scores = np.asarray(self.model.predict(x[None], verbose=0))[0]
        if c['output'] == 'logits':
            scores = np.exp(scores - scores.max())
            scores /= scores.sum()
        if not np.all(np.isfinite(scores)) or np.any(scores < 0) or np.any(scores > 1) or not np.isclose(scores.sum(), 1, atol=.01):
            raise ValueError('Invalid model probabilities')
        index = int(scores.argmax())
        return c['class_ids'][index], float(scores[index])
