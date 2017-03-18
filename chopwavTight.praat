# ------------------------------------------------------------------------
#
# chopwavTight.praat
#
# This script tightly chops out an .wav file
# to have NO silence (defined as less than 50 dB) before and after the recording.
# 
#
# Yejin Cho (scarletcho@gmail.com)
#
# NB. This is written referring to 'AnalyzeFrame' within 'pitch_listing.praat':
#     http://www.ucl.ac.uk/~ucjt465/scripts/praat/pitch_listing.praat
#
# ------------------------------------------------------------------------

form chopwav
    comment Directory of input wav files:
    text InputDir /Users/Scarlet_Mac/Downloads/mywav_in/
    comment Directory to save the chopped output files:
    text SaveDir /Users/Scarlet_Mac/Downloads/mywav_out/
endform


# List up filenames in inputDir
Create Strings as file list... wavlist 'inputDir$'/*.wav
n = Get number of strings


# for loop in i=1:n (for total number of files)
for i to n
  # Select filename list (named 'wavlist')
  select Strings wavlist

  # Get the first filename
  wavname$ = Get string... i
  fname$ = wavname$ - ".wav"
  writeInfoLine: inputDir$, "/", wavname$

  # Read from file and Select
  Read from file... 'inputDir$'/'wavname$'
  select Sound 'fname$'
  appendInfoLine: fname$


  # Get intensity
  intensity = To Intensity... 1000 0
  table = Create Table with column names... 'fname$'_dB 0 time dB
  for j to Object_'intensity'.nx
    call AnalyzeFrame
  endfor


  # Get time range of non-silence intensities
  nframes = Get number of rows
  
  # Initial values set-up
  iframe = 0
  dBval = 0
  k = 0
  Create Table with column names... 'fname$'_nonsildB 0 time dB

  for iframe to nframes
    select Table 'fname$'_dB
    dBval = Get value... iframe dB
    timeval = Get value... iframe time

    if dBval > 15
	  k = k + 1
      select Table 'fname$'_nonsildB
      Append row
      Set numeric value... k time timeval
      Set numeric value... k dB dBval
    endif
  endfor

  select Table 'fname$'_nonsildB
  nframes_nonsil = Get number of rows

  time_init = Get value... 1 time
  time_end = Get value... nframes_nonsil time
  appendInfoLine: time_init, " : ", time_end


  # Extract part
  select Sound 'fname$'
  Extract part... time_init time_end rectangular 1 yes
  Write to WAV file... 'saveDir$'/'fname$'.wav

  Remove
endfor


# ------------------------------------------------------------
# AnalyzeFrame
procedure AnalyzeFrame
  select intensity
  time = Get time from frame number... j
  dB = Get value in frame... j
  if dB != undefined
    select table
    Append row
    Set numeric value... Object_'table'.nrow time 'time:3'
    Set numeric value... Object_'table'.nrow dB 'dB:2'
  endif
endproc
# ------------------------------------------------------------


