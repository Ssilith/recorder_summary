import numpy as np
import scipy.signal


def spectral_subtraction(y, sr, noise_frames=10, alpha=4):
    """
    Perform spectral subtraction.

    Parameters:
        y (np.array): Input audio signal.
        sr (int): Sampling rate of the audio signal.
        noise_frames (int): Number of frames to consider as noise.
        alpha (float): Overestimation factor for noise.

    Returns:
        np.array: Noise-reduced signal.
    """
    # Frame size and overlap
    frame_size = int(0.032 * sr)  # 32 ms frame
    hop_size = frame_size // 2  # 50% overlap

    # Compute the short-time Fourier transform (STFT)
    f, t, Zxx = scipy.signal.stft(
        y, fs=sr, window="hann", nperseg=frame_size, noverlap=hop_size, nfft=2048
    )
    Zxx_mag = np.abs(Zxx)
    Zxx_phase = np.angle(Zxx)

    # Estimate the noise spectrum using the first few frames assumed to be noise
    noise_spectrum = np.mean(Zxx_mag[:, :noise_frames], axis=1)

    # Spectral subtraction
    subtracted_spectrum = Zxx_mag - alpha * noise_spectrum[:, np.newaxis]
    subtracted_spectrum[subtracted_spectrum < 0] = 0

    # Reconstruct signal
    y_reconstructed = scipy.signal.istft(
        subtracted_spectrum * np.exp(1j * Zxx_phase),
        fs=sr,
        window="hann",
        nperseg=frame_size,
        noverlap=hop_size,
        nfft=2048,
    )[1]

    return y_reconstructed
