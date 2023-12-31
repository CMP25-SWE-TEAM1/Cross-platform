///
/// This file generally contains global constants used
/// in various places inside the application


const String API_LINK = "backend.gigachat.cloudns.org";
const String API_WEBSOCKS_LINK = "http://51.116.199.56:5750/";

const Duration API_TIMEOUT = Duration(seconds: 5);
const int DEFAULT_PAGE_COUNT = 10;
const String USER_DEFAULT_PROFILE = "https://cdn.oneesports.gg/cdn-data/2022/10/GenshinImpact_Nahida_CloseUp.jpg";

const String APP_NAME = "gigachat";

// global constants
const double LOGIN_PAGE_PADDING = 10.0;
const double CREATE_POST_POPUP_PADDING = 32;
const int MEDIA_UPLOAD_LIMIT = 4;
const double MAX_POST_LENGTH = 200;


// constants for the tweet widget
const int MAX_LINES_TO_SHOW = 8;

enum ProviderFunction{
  HOME_PAGE_TWEETS,
  HOME_PAGE_MENTIONS,
  PROFILE_PAGE_TWEETS,
  PROFILE_PAGE_LIKES,
  PROFILE_PAGE_MEDIA,
  PROFILE_PAGE_REPLIES,
  GET_TWEET_COMMENTS,
  SEARCH_USERS,
  SEARCH_TWEETS,
  GET_USER_FOLLOWERS,
  GET_USER_FOLLOWINGS,
  GET_TWEET_LIKERS,
  GET_TWEET_REPOSTERS,
  GET_USER_BLOCKLIST,
  GET_USER_MUTEDLIST,
  GET_TRENDS,
  NONE
}

enum ProviderResultType{
  USER_RESULT,
  TWEET_RESULT,
  TREND_RESULT
}