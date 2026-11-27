Place the original `crop_disease_model.keras` and verified `model_config.json` here. Neither is committed. Do not guess class order or preprocessing.

Required configuration keys:

```json
{
  "verified_from_training": true,
  "class_ids": ["REPLACE WITH ALL TEN IDS IN THE EXACT TRAINING OUTPUT ORDER"],
  "input_size": [224, 224],
  "preprocessing": "mobilenet_v2",
  "resize": "bilinear",
  "output": "probabilities"
}
```

The values above are schema examples, NOT verified training settings. Supported preprocessing: `mobilenet_v2` (-1 to 1), `zero_one`, `raw_0_255` (including when preprocessing is embedded in the model). Supported resize: nearest/bilinear/bicubic. Output: probabilities/logits. Only the original training notebook or exported metadata can establish the right choices. Other preprocessing needs an explicit implementation before enabling inference.

Use IDs from `app/data/diseases.json`. The UI library order is NOT a training class order. The backend refuses to enable inference without this metadata and a valid ten-class model. The model does not detect non-leaf inputs or establish diagnosis; confidence is not calibrated accuracy.
