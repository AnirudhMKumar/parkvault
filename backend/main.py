import os
os.environ['KMP_DUPLICATE_LIB_OK'] = 'True'

import io
import cv2
import easyocr
import numpy as np
import re
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse

app = FastAPI(title="ParkVault AI API")

# Initialize EasyOCR Reader (will download model on first run if not cached)
# Use 'gpu=True' if CUDA is available, otherwise default 'gpu=False' works fine on modern CPUs for small images.
reader = easyocr.Reader(['en'], gpu=False)

def clean_plate_string(text: str) -> str:
    # Basic cleanup: remove extra spaces and characters that aren't letters/numbers
    cleaned = re.sub(r'[^A-Z0-9]', '', text.upper())
    return cleaned

@app.post("/detect-plate")
async def detect_plate(file: UploadFile = File(...)):
    try:
        # Read image to memory
        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            return JSONResponse(status_code=400, content={"error": "Invalid image file"})

        # Run EasyOCR
        results = reader.readtext(img)

        text_fragments = []
        for (bbox, text, prob) in results:
            if prob > 0.15:
                clean_text = re.sub(r'[^A-Z0-9]', '', text.upper())
                if len(clean_text) > 0:
                    text_fragments.append(clean_text)

        combined_text = "".join(text_fragments)
        
        # 1. Try strict vehicle plate regex (e.g. MH12AB1234)
        match = re.search(r'([A-Z]{2}[0-9]{1,2}[A-Z]{0,3}[0-9]{3,4})', combined_text)
        
        if match:
            cleaned_plate = match.group(1)
        elif len(text_fragments) > 0:
            # 2. Fallback: If no strict match and we have text, try to just combine it safely.
            if len(combined_text) <= 12:
                cleaned_plate = combined_text
            else:
                # If there's too much text (e.g. dealership name, bumper stickers)
                # just pick the longest continuous alphanumeric chunk.
                cleaned_plate = max(text_fragments, key=len)
        else:
            cleaned_plate = ""

        # Send it back to flutter
        return {"plate": cleaned_plate, "confidence": 1.0, "raw_text": combined_text}

    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.get("/")
def read_root():
    return {"message": "ParkVault AI Edge Server Running"}
