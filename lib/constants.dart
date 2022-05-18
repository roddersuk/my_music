// General
const String kTitle = "Rod's Music Selector";
const String kAuthor = 'Rod Thomas';
const String kVersion = '0.1';
const String kLegalese = '© 2022 RJT';
const String kAbout = 'I developed this app because the Yamaha MusicCast app has no search capability. '
    'It uses the REST interface of a TwonkyServer to search for and play the music.';

// Indices for the TabBar screens
const int kSearchScreenIndex = 0;
const int kSelectScreenIndex = 1;
const int kSpeakerScreenIndex = 2;
const int kPlayScreenIndex = 3;
const int kPlaylistScreenIndex = 4;

const int kResultsBatchSize = 10;

// Twonky
const String kTwonkyIPAddress = '192.168.1.107';
const int kTwonkyPort = 9000;
const String kTwonkyIPAddressKey = 'key_twonky_ip';
const String kTwonkyPortKey = 'key_twonky_port';
const String kTwonkyConnected = "Twonky server connected";
const String kTwonkyNotConnected = "Twonky server not connected";

// Media
const String kMediaArtist = 'Artist';
const String kMediaAlbum = 'Album';
const String kMediaTrack = 'Track';
const String kMediaGenre = 'Genre';
const String kMediaYear = 'Year';

// Page
const String kPageSearch = 'Search';
const String kPageSelect = 'Select';
const String kPageSpeakers = 'Speakers';
const String kPagePlay = 'Play';
const String kPagePlaylist = 'Playlist';

// Search
const String kSearchPrompt = 'Enter the search criteria';
const String kSearchText = 'The results will match items that contain the text and will be be ANDed together';
const String kSearchNoCriteria = 'No search criteria specified';
const String kSearchTooltip = 'Search for music';
const String kSearchArtistHint = 'Enter an artist name';
const String kSearchAlbumKey = 'key_search_album';
const String kSearchAlbumHint = 'Enter an album title';
const String kSearchTrackKey = 'key_search_track';
const String kSearchTrackHint = 'Enter the name of a track';
const String kSearchGenreKey = 'key_search_genre';
const String kSearchGenreHint = 'Enter a genre';
const String kSearchYearKey = 'key_Search_year';
const String kSearchYearHint = 'Enter a year';


// Settings
const String kSettingsTitle = 'Application Settings';
const String kSettingsReset = 'Reset settings';
const String kSettingsTwonkyIP = 'Twonky IP Address';
const String kSettingsTwonkyIPFormat = 'Must be 4 numbers separated by dots';
const String kSettingsTwonkyIPValues = 'Must be numbers between 0 and 255';
const String kSettingsTwonkyPort = 'Twonky Port';
const String kSettingsTwonkyPortValues = 'Port must be between 1024 and 65535';
const String kSettingsNotBlank = 'Cannot be blank';
const String kSettingsInvalidChars = 'Invalid characters';

// Select
const String kSelectPrompt = 'Tap to select';
const String kSelectNoResults = 'No results';
const String kSelectNothingSelected = 'Nothing selected';
const String kSelectActionTooltip = 'Play selection';
const String kSelectBy = 'by';

// Renderers
const String kRenderersPrompt = 'Select the speaker(s)';
const String kRenderersNoSpeakers = 'No speakers';
const String kRenderersNoMusic = 'No music selected';
const String kRenderersNoSelection = 'Select at least one speaker';
const String kRenderersTooltip = 'Play';
const String kRenderersFailedInit = 'Failed to initialise the selected renderer rc=';

// Playlist
const String kPlayNoSpeaker = 'Choose a speaker!';
const String kPlayNoMusic = 'No playlist - choose some tracks!';

// Media types
const String kMusicItem = 'musicItem';
const String kMusicAlbum = 'musicAlbum';

// Menu
const String kMenuClearSearch = 'Clear';
const String kMenuSettings = 'Settings';
const String kMenuAbout = 'About';

// WoL MAC lookup
const Map<String,String> kDeviceMacAddresses = {
  'QE65Q80RATXXU': 'D0:03:DF:C0:47:34',
  'UE55KU6000': '40:16:3B:00:BA:84',
};