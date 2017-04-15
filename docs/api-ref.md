# API Documentation

#### `/movies`
```json
[  
  {  
    "id":1,
    "title":"Beauty And The Beast",
    "language":"English",
    "age_rating":"PG",
    "duration_mins":129,
    "genres":[  
      "Fantasy",
      "Romance",
      "Musical"
    ]
  },
  {  
    "id":2,
    "title":"The Boss Baby",
    "language":"English",
    "age_rating":"PG",
    "duration_mins":98,
    "genres":[  
      "Animation"
    ]
  }
]
```


#### `/movies/1`
```json
{
  "id":1,
  "title":"Beauty And The Beast",
  "language":"English",
  "age_rating":"PG",
  "duration_mins":129,
  "genres":[
    "Fantasy",
    "Romance",
    "Musical"
  ]
}
```

#### `/movies/1/today`
```json
[
  {
    "cinema":"Shaw JCube",
    "showtimes":[
      "2017-04-02T00:10:00+08:00",
      "2017-04-02T12:50:00+08:00",
      "2017-04-02T16:00:00+08:00",
      "2017-04-02T18:30:00+08:00",
      "2017-04-02T21:20:00+08:00"
    ]
  },
  {
    "cinema":"Shaw Lido",
    "showtimes":[
      "2017-04-02T10:15:00+08:00",
      "2017-04-02T16:00:00+08:00",
      "2017-04-02T18:40:00+08:00",
      "2017-04-02T21:20:00+08:00"
    ]
  }
]
```

### `/cinemas`
```json
[
  {
    "id":1,
    "name":"Cathay AMK Hub"
  },
  {
    "id":2,
    "name":"Cathay Causeway Point"
  },
  {
    "id":3,
    "name":"Cathay Cineleisure"
  }
]
```

### `/cinemas/1`
```json
{
  "id":1,
  "name":"Cathay AMK Hub"
}
```

### `/cinemas/1/today`
```json
[
  {
    "movie":"Beauty And The Beast",
    "showtimes":[
      "2017-04-15T23:40:00+08:00"
    ]
  },
  {
    "movie":"Power Rangers",
    "showtimes":[
      "2017-04-15T21:55:00+08:00"
    ]
  },
  {
    "movie":"The Boss Baby",
    "showtimes":[
      "2017-04-15T18:30:00+08:00",
      "2017-04-15T20:45:00+08:00",
      "2017-04-15T23:00:00+08:00"
    ]
  }
]
```
