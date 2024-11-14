import 'package:flutter/material.dart';
import 'package:recorder_summary/services/noise_reduction_service.dart';

enum NoiseReduction {
  spectralSubtraction,
  wienerFilter,
  medianFilterSpectrogram
}

class BottomModalSettings extends StatefulWidget {
  final String recordingPath;
  const BottomModalSettings({super.key, required this.recordingPath});

  @override
  State<BottomModalSettings> createState() => _BottomModalSettingsState();
}

class _BottomModalSettingsState extends State<BottomModalSettings> {
  _sentToNoiseReductionApi() async {
    await NoiseReductionService()
        .uploadAudioFile(widget.recordingPath, "median_filter_spectrogram");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton(
            items: NoiseReduction.values
                .map((item) => DropdownMenuItem<String>(
                      value: item.name,
                      child: Text(
                        item.name,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ))
                .toList(),
            onChanged: (value) {})
      ],
    );
  }
}
