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


#### `/movie/1`
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

#### `/movie/1/today`
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
