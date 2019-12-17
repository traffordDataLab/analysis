library(rtweet) 

# tweets mentioning @TraffordCouncil or the phrase "Trafford Council"
mentions <- search_tweets(q = '@TraffordCouncil OR "Trafford Council"', n = 18000, include_rts = FALSE, `-filter` = "replies", retryonratelimit = TRUE, lang = "en")
write_as_csv(mentions, "data/mentions.csv")

# last 1000 tweets by @TraffordCouncil
tweets <- get_timeline(user = "TraffordCouncil", n = 1000)
write_as_csv(tweets, "data/tweets.csv")

# last 1000 likes by @TraffordCouncil
likes <- get_favorites("TraffordCouncil", n = 1000)
write_as_csv(likes, "data/likes.csv")