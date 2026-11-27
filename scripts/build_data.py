import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
entries = [
 ('bacterial_spot','Bacterial spot','Bacterial','Xanthomonas species','Small dark spots may appear on leaves.','ఆకులపై చిన్న నల్ల మచ్చలు కనిపించవచ్చు.'),
 ('early_blight','Early blight','Fungal','Alternaria species','Brown spots with concentric rings may begin on older leaves.','పాత ఆకులపై వలయాలతో గోధుమ మచ్చలు కనిపించవచ్చు.'),
 ('healthy','Healthy','Healthy','Solanum lycopersicum','No disease class detected does not rule out other crop problems.','వ్యాధి గుర్తించకపోయినా ఇతర సమస్యలు ఉండవచ్చు.'),
 ('late_blight','Late blight','Oomycete','Phytophthora infestans','Dark, water-soaked patches may spread across leaves.','నీటితో తడిసినట్లుగా నల్ల మచ్చలు ఆకులపై వ్యాపించవచ్చు.'),
 ('leaf_mold','Leaf mold','Fungal','Passalora fulva','Pale upper leaf patches may accompany mold beneath the leaf.','ఆకు పైభాగంలో లేత మచ్చలు, కింద బూజు కనిపించవచ్చు.'),
 ('septoria','Septoria leaf spot','Fungal','Septoria lycopersici','Small circular spots may have lighter centers.','చిన్న గుండ్రని మచ్చల మధ్య భాగం లేత రంగులో ఉండవచ్చు.'),
 ('spider_mite','Two-spotted spider mite','Pest','Tetranychus urticae','Fine stippling and webbing may occur.','ఆకులపై చిన్న చుక్కలు మరియు సాలెగూడు కనిపించవచ్చు.'),
 ('target_spot','Target spot','Fungal','Corynespora cassiicola','Brown lesions may have a target-like pattern.','గోధుమ మచ్చలు వలయాల రూపంలో కనిపించవచ్చు.'),
 ('mosaic_virus','Mosaic virus','Viral','Tomato mosaic virus','Mottled light and dark green leaves may be distorted.','ఆకులపై లేత, ముదురు ఆకుపచ్చ మచ్చలు మరియు వంకరలు కనిపించవచ్చు.'),
 ('yellow_leaf_curl','Yellow leaf curl virus','Viral','Tomato yellow leaf curl virus','Yellowing, curled leaves and stunting may occur.','ఆకులు పసుపు రంగులోకి మారడం, ముడుచుకోవడం, పెరుగుదల తగ్గడం కనిపించవచ్చు.'),
]
data=[dict(id=i,name=n,category=c,scientific=s,symptoms=en,symptoms_te=te,verified=False,source='https://apps.extension.umn.edu/garden/diagnose/plant/vegetable/tomato/') for i,n,c,s,en,te in entries]
for path in ['frontend/assets/data/diseases.json','backend/app/data/diseases.json']:
 p=ROOT/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(data,ensure_ascii=False,indent=2),encoding='utf-8')

# key | English | Telugu. ARB resources are loaded by Flutter's LocalizationsDelegate.
rows='''temporaryServer|This free demo server uses temporary storage. Accounts and server scan records may be erased when it restarts. Guest demo history stays on your device.|ఈ ఉచిత డెమో సర్వర్ తాత్కాలిక నిల్వను ఉపయోగిస్తుంది. సర్వర్ పునఃప్రారంభమైనప్పుడు ఖాతాలు, సర్వర్ స్కాన్ రికార్డులు తొలగిపోవచ్చు. అతిథి డెమో చరిత్ర మీ పరికరంలోనే ఉంటుంది.
tagline|Healthy Crops. Better Harvests.|ఆరోగ్యకరమైన పంటలు, మెరుగైన దిగుబడి.
welcome|A little care. A better harvest.|కొంచెం సంరక్షణ. మెరుగైన పంట.
chooseLanguage|Choose your language|మీ భాషను ఎంచుకోండి
continue|Continue|కొనసాగించు
skip|Skip for now|ప్రస్తుతానికి దాటవేయి
next|Next|తరువాత
start|Get started|ప్రారంభించండి
onboard1|Your leaf tells a story.|మీ ఆకు ఒక కథ చెబుతుంది.
onboard1Body|Photograph one tomato leaf in natural light. Give your crop the attention it deserves.|సహజ వెలుతురులో ఒక టమాటా ఆకును చిత్రీకరించండి. మీ పంటకు తగిన శ్రద్ధ ఇవ్వండి.
onboard2|Understand the early signs.|ప్రారంభ లక్షణాలను అర్థం చేసుకోండి.
onboard2Body|Explore possible diseases with AI assistance. A prediction is never a guaranteed diagnosis.|AI సహాయంతో సంభావ్య వ్యాధులను తెలుసుకోండి. అంచనా ఖచ్చితమైన నిర్ధారణ కాదు.
onboard3|Grow with confidence.|నమ్మకంతో సాగు చేయండి.
onboard3Body|Keep a crop record and learn when to seek advice from a local agricultural expert.|పంట రికార్డులను భద్రపరచండి. స్థానిక వ్యవసాయ నిపుణుల సలహా తీసుకోండి.
home|Home|హోమ్
diseases|Diseases|వ్యాధులు
scan|Scan|స్కాన్
history|History|చరిత్ర
profile|Profile|ప్రొఫైల్
greeting|Hello, grower.|నమస్కారం రైతు మిత్రమా!
hero|Protect your crops. Protect your harvest.|మీ పంటలను రక్షించండి. మీ దిగుబడిని కాపాడుకోండి.
heroBody|Thoughtful care for every tomato leaf.|ప్రతి టమాటా ఆకుకు శ్రద్ధతో సంరక్షణ.
scanCrop|Scan your crop|మీ పంటను స్కాన్ చేయండి
camera|Camera|కెమెరా
gallery|Gallery|గ్యాలరీ
yourCrops|Rooted in your fields|మీ పొలాల కోసం
tomato|Tomato|టమాటా
chilli|Chilli|మిరప
cotton|Cotton|పత్తి
paddy|Paddy|వరి
maize|Maize|మొక్కజొన్న
groundnut|Groundnut|వేరుశనగ
available|Ready to scan|స్కాన్ అందుబాటులో ఉంది
soon|Coming soon|త్వరలో
allCrops|Explore crops|పంటలను చూడండి
recent|Recent observations|ఇటీవలి పరిశీలనలు
viewAll|View all|అన్నీ చూడండి
tip|A moment in the field|పొలంలో ఒక క్షణం
tipBody|Check both sides of a leaf. Similar symptoms can have different causes. A clear photograph helps an expert understand the problem.|ఆకుకు రెండు వైపులా చూడండి. ఒకే లక్షణాలకు వేర్వేరు కారణాలు ఉండవచ్చు. స్పష్టమైన చిత్రం నిపుణులకు సహాయపడుతుంది.
noScans|Your crop story starts here.|మీ పంట కథ ఇక్కడ మొదలవుతుంది.
noScansBody|Take your first leaf photo. Your observations will appear here.|మొదటి ఆకు ఫోటో తీయండి. మీ పరిశీలనలు ఇక్కడ కనిపిస్తాయి.
demo|Demo mode|డెమో మోడ్
live|Live mode|లైవ్ మోడ్
demoNotice|Demonstration only. The selected scenario is not a diagnosis of your photo.|ప్రదర్శన కోసం మాత్రమే. ఎంచుకున్న దృశ్యం మీ ఫోటోకు వ్యాధి నిర్ధారణ కాదు.
login|Sign in|లాగిన్
register|Create account|ఖాతా సృష్టించండి
guest|Continue as guest|అతిథిగా కొనసాగించండి
authNote|Guest access works offline. Sign in connects to your configured CropCare server.|అతిథి ప్రవేశం ఆఫ్‌లైన్‌లో పనిచేస్తుంది. లాగిన్ మీ CropCare సర్వర్‌కు అనుసంధానిస్తుంది.
name|Farmer name|రైతు పేరు
mobile|Mobile number|మొబైల్ నంబర్
email|Email (optional)|ఇమెయిల్ (ఐచ్ఛికం)
identifier|Mobile number or email|మొబైల్ నంబర్ లేదా ఇమెయిల్
password|Password|పాస్‌వర్డ్
passwordHint|Use at least 10 characters|కనీసం 10 అక్షరాలు ఉపయోగించండి
required|Please check the required fields.|అవసరమైన వివరాలను సరిచూడండి.
error|Something went wrong. Please try again.|లోపం ఏర్పడింది. మళ్లీ ప్రయత్నించండి.
location|Your growing place|మీ సాగు ప్రాంతం
locationBody|Location is optional and stays on this device. Enter your own administrative details.|లొకేషన్ ఐచ్ఛికం, ఈ పరికరంలోనే ఉంటుంది. మీ ప్రాంత వివరాలను నమోదు చేయండి.
currentLocation|Use my current location|నా ప్రస్తుత లొకేషన్ ఉపయోగించు
manual|Enter location manually|లొకేషన్‌ను నమోదు చేయండి
state|State|రాష్ట్రం
district|District|జిల్లా
mandal|Mandal / subdistrict|మండలం
village|Village / town|గ్రామం / పట్టణం
save|Save|భద్రపరచు
notSet|Choose your location|మీ లొకేషన్ ఎంచుకోండి
gpsError|Location unavailable or permission denied. You can enter it manually.|లొకేషన్ అందుబాటులో లేదు లేదా అనుమతి లేదు. వివరాలను నమోదు చేయవచ్చు.
library|Know your leaves.|మీ ఆకులను తెలుసుకోండి.
libraryBody|A field companion for tomato growers.|టమాటా రైతుల కోసం మార్గదర్శి.
search|Search|వెతకండి
all|All|అన్నీ
Fungal|Fungal|శిలీంధ్రం
Bacterial|Bacterial|బ్యాక్టీరియా
Viral|Viral|వైరస్
Pest|Pest|పురుగు
Healthy|Healthy|ఆరోగ్యకరం
Oomycete|Oomycete|ఊమైసీట్
noResults|No matching observations.|సరిపోలే పరిశీలనలు లేవు.
symptoms|What to look for|గమనించాల్సిన లక్షణాలు
prevention|Care & prevention|సంరక్షణ మరియు నివారణ
guidance|Expert guidance|నిపుణుల మార్గదర్శకత్వం
careBody|Keep tools clean, observe plants regularly and discuss suitable crop management with a local agricultural expert.|పరికరాలను శుభ్రంగా ఉంచండి. మొక్కలను క్రమంగా పరిశీలించండి. తగిన పంట నిర్వహణకు స్థానిక వ్యవసాయ నిపుణులను సంప్రదించండి.
expertBody|Confirm the cause before treatment. No pesticide or dosage is recommended by this app. Viral diseases are not cured by pesticides.|చికిత్సకు ముందు కారణాన్ని నిర్ధారించండి. ఈ యాప్ పురుగుమందులు లేదా మోతాదులను సూచించదు. వైరస్ వ్యాధులు పురుగుమందులతో నయం కావు.
unverified|Starter educational content — not locally expert-verified. Telugu disease names are omitted until verified.|ప్రాథమిక అవగాహన సమాచారం — స్థానిక నిపుణులు ధృవీకరించలేదు. ధృవీకరణ వరకు తెలుగు వ్యాధి పేర్లు ఇవ్వబడలేదు.
source|Open reference guide|ఆధార మార్గదర్శిని తెరవండి
scannerTitle|One leaf. A closer look.|ఒక ఆకు. నిశిత పరిశీలన.
scanInstructions|Place one leaf inside the guide. Use natural light, keep steady and capture visible symptoms.|ఒక ఆకును ఫ్రేమ్‌లో ఉంచండి. సహజ వెలుతురులో కదలకుండా లక్షణాలను చిత్రీకరించండి.
openCamera|Open camera|కెమెరా తెరవండి
capture|Capture leaf|ఆకును చిత్రీకరించండి
flash|Toggle flash|ఫ్లాష్ మార్చండి
cameraError|Camera unavailable. Check permission or choose a photo from your gallery.|కెమెరా అందుబాటులో లేదు. అనుమతి సరిచూడండి లేదా గ్యాలరీ నుండి ఫోటో ఎంచుకోండి.
preview|A good look before we begin.|ప్రారంభించే ముందు చిత్రాన్ని చూడండి.
retake|Retake photo|ఫోటో మళ్లీ తీయండి
changeImage|Change image|చిత్రం మార్చండి
analyze|Analyze crop|పంట విశ్లేషించండి
badImage|Choose a JPEG, PNG or WebP photo under 8 MB, at least 64 pixels on each side.|8 MB లోపు, కనీసం 64 పిక్సెల్‌ల JPEG, PNG లేదా WebP ఫోటో ఎంచుకోండి.
scenario|Choose demonstration scenario|ప్రదర్శన దృశ్యాన్ని ఎంచుకోండి
scenarioEarly|Early blight example|Early blight ఉదాహరణ
scenarioHealthy|Healthy leaf example|ఆరోగ్యకరమైన ఆకు ఉదాహరణ
scenarioLow|Uncertain result example|అనిశ్చిత ఫలితం ఉదాహరణ
processing|Looking a little closer…|మరింత దగ్గరగా పరిశీలిస్తున్నాం…
stage1|Checking image quality|చిత్ర నాణ్యత తనిఖీ
stage2|Analyzing leaf patterns|ఆకు నమూనాల విశ్లేషణ
stage3|Retrieving disease information|వ్యాధి సమాచారం పొందుతోంది
possible|Possible condition|సంభావ్య పరిస్థితి
confidence|Model confidence|మోడల్ నమ్మకం
demoConfidence|Illustrative confidence|ఉదాహరణ నమ్మకం
high|High|అధికం
medium|Medium|మధ్యస్థం
low|Low|తక్కువ
uncertain|This result is uncertain. Retake a clear photo and ask a local agricultural expert before acting.|ఈ ఫలితం అనిశ్చితం. స్పష్టమైన ఫోటో మళ్లీ తీసి, చర్యకు ముందు స్థానిక వ్యవసాయ నిపుణులను సంప్రదించండి.
resultWarning|AI assistance, not a confirmed diagnosis. Confidence is not a guarantee of correctness.|AI సహాయం మాత్రమే, నిర్ధారణ కాదు. నమ్మకం శాతం ఖచ్చితత్వానికి హామీ కాదు.
delete|Delete|తొలగించు
deleteQuestion|Delete this scan and its stored photo?|ఈ స్కాన్ మరియు భద్రపరచిన ఫోటో తొలగించాలా?
cancel|Cancel|రద్దు
deleteAll|Clear local history|స్థానిక చరిత్ర తొలగించు
clearQuestion|Remove all demonstration scans and their photos from this device?|ఈ పరికరంలోని అన్ని డెమో స్కాన్లు, ఫోటోలు తొలగించాలా?
settings|Make it yours.|మీకు అనుగుణంగా మార్చుకోండి.
language|Language|భాష
privacy|Privacy & storage|గోప్యత మరియు నిల్వ
privacyBody|Demo photos stay on this device. Live photos are sent to your server and stored with your account. Deleting a scan removes its stored image. Sign in again after restarting.|డెమో ఫోటోలు ఈ పరికరంలో ఉంటాయి. లైవ్ ఫోటోలు మీ సర్వర్‌లో మీ ఖాతాతో నిల్వ అవుతాయి. స్కాన్ తొలగిస్తే చిత్రం కూడా తొలగుతుంది. పునఃప్రారంభించినప్పుడు మళ్లీ లాగిన్ అవ్వండి.
help|A helping hand|సహాయ హస్తం
about|About CropCare|CropCare గురించి
aboutBody|Thoughtful tomato crop care. Live mode requires your trained model and verified configuration.|శ్రద్ధతో టమాటా పంట సంరక్షణ. లైవ్‌కు శిక్షణ పొందిన మోడల్ మరియు ధృవీకరించిన కాన్ఫిగరేషన్ అవసరం.
logout|Sign out / leave guest session|లాగ్ అవుట్ / అతిథి ప్రవేశం ముగించు
server|Backend address|బ్యాకెండ్ చిరునామా
serverHint|Example: https://api.example.com|ఉదాహరణ: https://api.example.com
serverSaved|Backend address saved.|బ్యాకెండ్ చిరునామా భద్రపరచబడింది.
serverInvalid|Use HTTPS, or HTTP for localhost / emulator development only.|HTTPS ఉపయోగించండి. స్థానిక అభివృద్ధికి మాత్రమే HTTP ఉపయోగించండి.
liveRequires|Sign in and configure a model-enabled backend to use live mode.|లైవ్ మోడ్ కోసం లాగిన్ చేసి మోడల్ ఉన్న బ్యాకెండ్‌ను ఎంచుకోండి.
observations|Saved observations|భద్రపరచిన పరిశీలనలు
guestName|Guest grower|అతిథి రైతు
saved|Saved|భద్రపరచబడింది
storageFull|Storage is full. Delete older scans and try again.|నిల్వ నిండింది. పాత స్కాన్లు తొలగించి మళ్లీ ప్రయత్నించండి.
refresh|Refresh|రిఫ్రెష్
offline|Could not connect. Demo mode is available offline.|కనెక్ట్ కాలేదు. డెమో మోడ్ ఆఫ్‌లైన్‌లో అందుబాటులో ఉంది.
signInNeeded|Sign in to continue|కొనసాగించడానికి లాగిన్ అవ్వండి'''
strings=[r.split('|') for r in rows.splitlines()]
for lang,index in [('en',1),('te',2)]:
 p=ROOT/f'frontend/lib/l10n/app_{lang}.arb';p.parent.mkdir(parents=True,exist_ok=True)
 p.write_text(json.dumps({'@@locale':lang,**{r[0]:r[index] for r in strings}},ensure_ascii=False,indent=2),encoding='utf-8')
