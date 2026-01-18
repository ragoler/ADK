from google import genai

client = genai.Client(
    vertexai=True,
    project='autoproject-ragoler',
    location='global' # Change this from us-central1
)

for m in client.models.list():
    #if 'gemini-3' in m.name:
    print(f"Found it: {m.name}")