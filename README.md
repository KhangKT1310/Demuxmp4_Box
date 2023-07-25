# MP4 Demuxer 

A simple implementation of mp4 demuxing, supports AVC/HEVC/AAC.

### Usage

Build Demuxer by:

```shell
mkdir cmake-build-debug && cd cmake-build-debug && cmake .. && make
# or
sh build.sh && cd cmake-build-debug
```

Run help by:

```shell
./mp4demuxer_c -h
```

```

Usage:
    mp4demuxer_c --input-file <input_file> [--output-folder<output_folder>] [--time-ranges <ranges>]

Option description:
    --input-file            Specifies the input file (.mp4) for demultiplex.
    --output-folder         Specifies the output folder path and name.
    --time-ranges           A time range (in seconds) to demultiplex.
    --version               Prints version information
    --help                  Displays help information
    --verbose               Displays More information for debugging.

Examples:
    1. Demux a mp4 file
      mp4demuxer_c --input-file input.mp4 --output-folder tmp

    2. Demux playloads of mp4 file with an indicated time range 
      from 0s to 5.2s: mp4demuxer_c --input-file input.mp4 --output-folder tmp --time-ranges 0-5.2
      from 4s to end: mp4demuxer_c --input-file input.mp4 --output-folder tmp --time-ranges 4-


```
Run Demuxer by:
```shell

 ./mp4demuxer --input-file ../docs/MPEG-4_P14_V2.mp4 --output-folder ./
```
After run demuxer, here is log:
```
./
Meta handler type is mdir, not 'ID32'
No ainf found
<?xml version="1.0" encoding="utf-8"?>
<mp4d_itunes_metadata>
<mp4d_itunes_metadata_item type="Encoding Tool">
<string><![CDATA[Lavf60.4.101]]></string>
</mp4d_itunes_metadata_item>
</mp4d_itunes_metadata>
Found trak:tkhd for track_ID = 1 (need 1)
Found trak:tkhd for track_ID = 2 (need 1)
stts at 0x55626bf57f51
ctts at (nil)
stsz/stz2 at 0x55626bf57f75
stsc at 0x55626bf57f61
stco/co64 at 0x55626bf57f85
stss at (nil)
elst at (nil)
subs at (nil)
number of saiz: 0
number of saio: 0
sdtp at (nil)
stdp at (nil)
padb at (nil)
empty *tts table
Found traf:tfhd for track_ID = 1 (need 1)
Found traf:tfhd for track_ID = 2 (need 1)
tf_flags = 59
base_data_offset = 1366
sample_description_index = 1
default_sample_duration = 512
default_sample_size = 47199
default_sample_flags = 16842752
Found trak:tkhd for track_ID = 1 (need 2)
Found trak:tkhd for track_ID = 2 (need 2)
stts at 0x55626bfbea45
ctts at (nil)
stsz/stz2 at 0x55626bfbea69
stsc at 0x55626bfbea55
stco/co64 at 0x55626bfbea79
stss at (nil)
elst at (nil)
subs at (nil)
number of saiz: 0
number of saio: 0
sdtp at (nil)
stdp at (nil)
padb at (nil)
empty *tts table
Found traf:tfhd for track_ID = 1 (need 2)
Found traf:tfhd for track_ID = 2 (need 2)
tf_flags = 59
base_data_offset = 1366
sample_description_index = 1
default_sample_duration = 2494
default_sample_size = 371
default_sample_flags = 33554432
track_ID 1: Out of trun(s) (after 1 trun(s))
Found traf:tfhd for track_ID = 1 (need 1)
Found traf:tfhd for track_ID = 2 (need 1)
tf_flags = 59
base_data_offset = 2427143
sample_description_index = 1
default_sample_duration = 512
default_sample_size = 37086
default_sample_flags = 16842752
track_ID 2: Out of trun(s) (after 1 trun(s))
Found traf:tfhd for track_ID = 1 (need 2)
Found traf:tfhd for track_ID = 2 (need 2)
tf_flags = 59
base_data_offset = 2427143
sample_description_index = 1
default_sample_duration = 1024
default_sample_size = 362
default_sample_flags = 33554432
track_ID 1: Out of trun(s) (after 1 trun(s))
Found traf:tfhd for track_ID = 1 (need 1)
Found traf:tfhd for track_ID = 2 (need 1)
tf_flags = 59
base_data_offset = 2975644
sample_description_index = 1
default_sample_duration = 512
default_sample_size = 46012
default_sample_flags = 16842752
track_ID 2: Out of trun(s) (after 1 trun(s))
Found traf:tfhd for track_ID = 1 (need 2)
Found traf:tfhd for track_ID = 2 (need 2)
tf_flags = 59
base_data_offset = 2975644
sample_description_index = 1
default_sample_duration = 1024
default_sample_size = 385
default_sample_flags = 33554432
track_ID 1: Out of trun(s) (after 1 trun(s))
track_ID 2: Out of trun(s) (after 1 trun(s))
```


Play the extracted file by:

```shell
ffplay out_2.aac
```

### Key points

My purpose is to parse the audio and video data in the `mp4` file and save it as a corresponding media file.

As we all know, the media data of `mp4` is stored in `mdat`, but `mdat` does not tell us what is audio/video data, so we need to rely on other `box` (mainly `stco`, `stsz`, `stsc`) to locate the audio and video data in `mdat`.

#### stco(Chunk Offset Box)

It is used to locate the block offset in the media data, because there are multiple blocks, so it is an array format, chunk_offsets[number_of_entries]
#### stsz(Sample Size Box)

Used to represent the size of each media `sample`, usually the size of `sample` is variable, sample_sizes[number_of_entries] saves the size of all samples

#### stsc(Sample-to-Chunk Box)

If you only know `stco` and `stsz`, you cannot locate the media data, so you need the corresponding table of `sample` and `chunk` to parse out the media data

The following tables are from `docs/qtff.pdf`

**Figure 2-47**    An example of a sample-to-chunk table

| First chunk | Samples per chunk | Sample description ID |
| :---------: | :---------------: | :-------------------: |
|      1      |         3         |           1           |
|      3      |         1         |           1           |
|      5      |         1         |           1           |

The following is the expanded table. It can be seen that `chunk` can be indexed by `stco`, and `sample` can be indexed by `stsz`.

|       |     First chunk      |   Samples per chunk   | Sample description ID |
| :---: | :------------------: | :-------------------: | :-------------------: |
|       |          1           |           3           |           1           |
| ***** |          2           |           3           |           1           |
|       |          3           |           1           |           1           |
| ***** |          4           |           1           |           1           |
|       |          5           |           1           |           1           |
|       | Number of chunks = 5 | Number of samples = 9 |                       |

#### 提取媒体数据

When extracting `avc`, a `sample` may contain multiple `nalu`, the format is ``` [nalu length(4bytes)][nalu data(nalu length bytes)]+[nalu length][nalu data]+...```. The same rule applies to the extraction of `hevc`.