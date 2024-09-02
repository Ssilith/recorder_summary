import numpy as np
import scipy.signal


def wiener_filter(y, sr, noise_frames=10):
    """
    Apply a Wiener filter for noise reduction.

    Parameters:
        y (np.array): Input audio signal.
        sr (int): Sampling rate of the audio signal.
        noise_frames (int): Number of frames considered to contain only noise.

    Returns:
        np.array: Noise-reduced signal.
    """
    # Frame size and overlap
    frame_size = int(0.032 * sr)  # 32 ms frame
    hop_size = frame_size // 2

    # Compute the STFT
    f, t, Zxx = scipy.signal.stft(
        y, fs=sr, window="hann", nperseg=frame_size, noverlap=hop_size
    )
    Zxx_mag = np.abs(Zxx)
    Zxx_phase = np.angle(Zxx)

    # Estimate noise power spectrum
    noise_power = np.mean(Zxx_mag[:, :noise_frames] ** 2, axis=1)

    # Wiener filter
    signal_power = np.abs(Zxx) ** 2
    eps = 1e-10  # Epsilon to avoid division by zero
    filter_gain = signal_power / (signal_power + noise_power[:, np.newaxis] + eps)
    filtered_spectrum = filter_gain * Zxx

    # Reconstruct signal
    y_reconstructed = scipy.signal.istft(
        filtered_spectrum, fs=sr, window="hann", nperseg=frame_size, noverlap=hop_size
    )[1]

    return y_reconstructed
