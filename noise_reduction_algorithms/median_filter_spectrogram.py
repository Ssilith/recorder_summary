import numpy as np
import scipy.signal


def median_filter_spectrogram(y, sr, kernel_size=3):
    """
    Apply median filtering to the spectrogram for noise reduction.

    Parameters:
        y (np.array): Input audio signal.
        sr (int): Sampling rate of the audio.
        kernel_size (int): Size of the median filter kernel.

    Returns:
        np.array: Noise-reduced signal.
    """
    # Frame size and overlap
    frame_size = int(0.032 * sr)
    hop_size = frame_size // 2

    # Compute the STFT
    f, t, Zxx = scipy.signal.stft(
        y, fs=sr, window="hann", nperseg=frame_size, noverlap=hop_size
    )
    Zxx_mag = np.abs(Zxx)
    Zxx_phase = np.angle(Zxx)

    # Median filtering on magnitude
    filtered_mag = scipy.signal.medfilt2d(Zxx_mag, kernel_size=(kernel_size, 1))

    # Reconstruct signal
    y_reconstructed = scipy.signal.istft(
        filtered_mag * np.exp(1j * Zxx_phase),
        fs=sr,
        window="hann",
        nperseg=frame_size,
        noverlap=hop_size,
    )[1]

    return y_reconstructed
