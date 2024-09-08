from wiener_filter import wiener_filter
from spectral_subtraction import spectral_subtraction
from median_filter_spectrogram import median_filter_spectrogram

from flask import Flask, request, send_file
from flask_cors import CORS
from pydub import AudioSegment
import numpy as np
from io import BytesIO
import os
import tempfile

app = Flask(__name__)
CORS(app)


@app.route("/process_audio", methods=["POST"])
def process_audio():
    # Get algorithm
    algorithm = request.args.get("algorithm", "spectral_subtraction")

    # Get file
    if "file" not in request.files:
        return "No file part", 400
    file = request.files["file"]
    if file.filename == "" or not file.filename.endswith(".m4a"):
        return "No selected file or unsupported file type", 400

    # Read file into bytes stream
    file_stream = BytesIO(file.read())
    try:
        data, sr = load_audio(file_stream)
    except Exception as e:
        return f"Error processing audio: {str(e)}", 500

    # Select the algorithm based on the request
    if algorithm == "spectral_subtraction":
        processed_data = spectral_subtraction(data, sr)
    elif algorithm == "wiener_filter":
        processed_data = wiener_filter(data, sr)
    elif algorithm == "median_filter_spectrogram":
        processed_data = median_filter_spectrogram(data, sr)
    else:
        processed_data = data

    # Temporary file for the output
    output_path = tempfile.NamedTemporaryFile(delete=False, suffix=".wav").name
    save_audio(processed_data, sr, output_path)
    return send_file(
        output_path, as_attachment=True, download_name="processed_output.wav"
    )


def load_audio(file_stream):
    # Load from bytes
    audio = AudioSegment.from_file(file_stream)
    samples = np.array(audio.get_array_of_samples())
    if audio.channels == 2:
        samples = samples.reshape((-1, 2))
        samples = samples.mean(axis=1)
    return samples, audio.frame_rate


def save_audio(output, sr, file_path="output.wav"):
    # Save audio
    output_segment = AudioSegment(
        output.tobytes(), frame_rate=sr, sample_width=output.dtype.itemsize, channels=1
    )
    output_segment.export(file_path, format="wav")


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
