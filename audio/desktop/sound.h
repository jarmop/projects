#include <alsa/asoundlib.h>
#include <math.h>
#include <stdio.h>

#define SAMPLE_RATE 44100
#define FREQUENCY 523.2511  // A4
#define DURATION 2          // seconds
#define AMPLITUDE 0.3

int play() {
  snd_pcm_t* handle;
  snd_pcm_hw_params_t* params;
  int dir;

  // Open default PCM device
  snd_pcm_open(&handle, "default", SND_PCM_STREAM_PLAYBACK, 0);

  // Allocate hardware parameters
  snd_pcm_hw_params_alloca(&params);
  snd_pcm_hw_params_any(handle, params);

  // Set parameters
  snd_pcm_hw_params_set_access(handle, params, SND_PCM_ACCESS_RW_INTERLEAVED);
  snd_pcm_hw_params_set_format(handle, params, SND_PCM_FORMAT_FLOAT_LE);
  snd_pcm_hw_params_set_channels(handle, params, 1);  // mono

  unsigned int rate = SAMPLE_RATE;
  snd_pcm_hw_params_set_rate_near(handle, params, &rate, &dir);

  snd_pcm_hw_params(handle, params);

  // Prepare device
  snd_pcm_prepare(handle);

  // Generate and play sine wave
  int total_frames = SAMPLE_RATE * DURATION;
  float buffer[1024];

  for (int i = 0; i < total_frames;) {
    int frames = (total_frames - i > 1024) ? 1024 : (total_frames - i);

    for (int j = 0; j < frames; j++) {
      float t = (float)(i + j) / SAMPLE_RATE;
      buffer[j] = AMPLITUDE * sinf(2.0f * M_PI * FREQUENCY * t);
    }

    int written = snd_pcm_writei(handle, buffer, frames);

    if (written < 0) {
      snd_pcm_prepare(handle);  // recover from underrun
    } else {
      i += written;
    }
  }

  snd_pcm_drain(handle);
  snd_pcm_close(handle);

  return 0;
}