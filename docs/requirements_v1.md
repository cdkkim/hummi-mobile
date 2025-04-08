# Hummi Product Requirements Document

## Eelevator Pitch
Hummi is a mobile application designed for amateur singers to practice building harmony with any base note. If a person records a voice, this app analyzes and produces 3rd and 5th pitch of the record. User can record and playback with buttons. When user is recording, frequency diagram like in iphone's voice memo application.

## Who is this App For
- **Amateur singers:** Individuals who want to practice building harmony with any base note.

## Functional Requirements

- **Voice Recording:**
    - A button to record a voice. When recording is in progress, this button switches to a stop button. When pressed, it stops recording and saves as a file.
    - A button to playback recorded voice.

## User Stories
- **Voice Record:**
_As an amateur signer, I want to quickly record my voice to check 3rd and 5th picth of the song_
_As an amateur signer, I want to quickly check original, 3rd and 5th pitch of recorded voice_
_As an amateur signer, I want to check all recordings sorted by creation time in a descending order_
_As an amateur signer, I want to delete with a button in the bottom right corer in each item_

## User Interface
- **Home Screen:**
 - A apple's voice memo like interface with recording list in the main area and record button in the bottom.

- **Recording Item:**
  - Each recording item looks like apple's voice memo: filename in the top, recorded time follows bellow. Then progress bar with length of recording. At the bottom, play button and delete button and 3rd pitch button and 5th pitch button.
  - When 3rd pitch button is pressed, 3rd pitch of recorded voice should play. When pressed again, stop playing.
  - When 5th pitch button is pressed, 5th pitch of recorded voice should play. When pressed again, stop playing.
