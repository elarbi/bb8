  
#
#Helper functions
#
#shuffle an array
shuffle = (source) ->
# Arrays with < 2 elements do not shuffle well. Instead make it a noop.
  return source unless source.length >= 2
  # From the end of the list to the beginning, pick element `index`.
  for index in [source.length - 1..1]
# Choose random element `randomIndex` to the front of `index` to swap with.
    randomIndex = Math.floor Math.random() * (index + 1)
    # Swap `randomIndex` with `index`, using destructured assignment
    [source[index], source[randomIndex]] = [source[randomIndex], source[index]]
  source

#decompose an array into chunks of a specific size
chunk = (arr, chunkSize) ->
  [].concat.apply [], arr.map((elem, i) ->
    (if i % chunkSize then [] else [arr.slice(i, i + chunkSize)])
  )

#


#map of all players and their rank see https://docs.google.com/spreadsheets/d/1Aa8kfIktTnbK6KjTqjuPacO0CGkPXvgF_i065vgslsQ
players = {
  KBO: 2.5,
  MER: 3.5,
  HED: 1.5,
  MEL: 5,
  OEL: 2,
  SBO: 2,
  YZA: 4.5,
  NAG: 5,
  AEL: 5,
  EAB: 3,
  MKA: 1.5,
  AGU: 4.5,
  MELK: 3.5,
  ANA: 2.5,
  ZHA: 4.5,
  ALA:2,
  XX1: 1,
  XX2: 2,
  XX3: 3,
  XX4: 4,
  XX5: 5
}

#map of trigrams and names
names = {
  KBO: "Khalid",
  MER: "Mouhcine",
  HED: "Hamza EDDARAKI",
  MEL: "Marouane",
  OEL: "Othman",
  SBO: "Soufiane",
  YZA: "Yahya",
  NAG: "Nizar",
  AEL: "Ayoub",
  EAB: "El Arbi",
  MKA: "Mohammed KADDOURI",
  AGU: "Abderrahim",
  MELK: "Mohammed ELKALAKHI",
  ANA: "Abdelouahed",
  ZHA: "Zakaria HAMZA",
  ALA: "Anwar",
  XX1: "XX1",
  XX2: "XX2",
  XX3: "XX3",
  XX4: "XX4",
  XX5: "XX5"
}

#order player names by their level
keysByValueOrder = (mymap) ->
#orders the key by their values
  keys = Object.keys(mymap).sort (a, b) -> mymap[b] - mymap[a]
  #console.log(keys)
  keys

generateTeams = (input) ->
#extract submap of next match players from all players map
  nextMatchPlayers = {}
  for player in input
    nextMatchPlayers[player] = players[player]
  #console.log(nextMatchPlayers)
  levelOrderedPlayers = keysByValueOrder(nextMatchPlayers)
  #console.log(levelOrderedPlayers)
  # Split global list into 3 sublists (2 top level players, 4 middle level, and 4 others)
  topPlayers = levelOrderedPlayers.slice(0, 0 + 2)
  middlePlayers = levelOrderedPlayers.slice(2, 2 + 4)
  otherPlayers = levelOrderedPlayers.slice(6, 6 + 4)
  # shuffle each list
  topPlayers = shuffle(topPlayers)
  middlePlayers = shuffle(middlePlayers)
  otherPlayers = shuffle(otherPlayers)
  # split each one into 2 lists and merge them into 2 teams
  [team11, team21] = chunk(topPlayers, 1)
  [team12, team22] = chunk(middlePlayers, 2)
  [team13, team23] = chunk(otherPlayers, 2)
  team1 = team11.concat team12.concat team13
  team2 = team21.concat team22.concat team23
  score1 = 0
  score2 = 0
  for p in team1
    score1 += nextMatchPlayers[p]
    console.log("team1 nextMatchPlayers[p]: "+nextMatchPlayers[p])
  for p in team2
    score2 += nextMatchPlayers[p]
    console.log("team1 nextMatchPlayers[p]: "+nextMatchPlayers[p])
  console.log("score1: "+score1)
  return {"team1": team1, "score1": score1, "team2": team2, "score2": score2}
  
module.exports = (robot) ->
  robot.hear /salam/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  robot.respond /open the (.*) doors/i, (res) ->
    doorType = res.match[1]
    if doorType is "pod bay"
      res.reply "I'm afraid I can't let you do that."
    else
      res.reply "Opening #{doorType} doors"

  robot.hear /foot players/i, (res) ->
    res.send "Those are registred players: KBO,MER,HED,MEL,OEL,SBO,YZA,NAG,AEL,EAB,MKA,AGU,MELK,ANA,ZHA,ALA,XX1,XX2,XX3,XX4 (an invited player with level4) \n Give me ten players from this list and say \"bb8 t3azila <listOfCommaSeparatedPlayers>\" and I'll give 2 nearly equivalent teams for free !"



#T3azila
  robot.hear /t3azila (.*)/i, (res) ->
    input = res.match[1].split ","
    console.log(input)
    if input.length isnt 10
      res.reply "Sorry it only works for ten players :( you give me #{input.length}"
    else
      result = generateTeams(input)
      score1 = result.score1
      team1_names = []
      for trig in result.team1
        team1_names.push names[trig] 
      team2_names = []
      for trig in result.team2
        team2_names.push names[trig]
      score2 = result.score2
      res.reply "Ok, so I propose: \n team1: #{team1_names} with score #{score1} \n Vs \n team2: #{team2_names} with score #{score2}"
