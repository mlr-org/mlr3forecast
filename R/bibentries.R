#' @importFrom utils bibentry
# nolint start
bibentries = c(
  bergmeir_2018 = bibentry(
    "article",
    title = "A note on the validity of cross-validation for evaluating autoregressive time series prediction",
    author = "Christoph Bergmeir and Rob J Hyndman and Bonsoo Koo",
    journal = "Computational Statistics & Data Analysis",
    volume = "120",
    pages = "70--83",
    year = "2018",
    publisher = "Elsevier"
  ),
  tashman2000 = bibentry(
    "article",
    title = "Out-of-sample tests of forecasting accuracy: an analysis and review",
    author = "Leonard J Tashman",
    journal = "International Journal of Forecasting",
    volume = "16",
    number = "4",
    pages = "437--450",
    year = "2000",
    publisher = "Elsevier"
  ),
  hyndman2008automatic = bibentry(
    "article",
    title = "Automatic Time Series Forecasting: The forecast Package for R",
    volume = "27",
    doi = "10.18637/jss.v027.i03",
    number = "3",
    journal = "Journal of Statistical Software",
    author = "Rob J Hyndman and Yeasmin Khandakar",
    year = "2008",
    pages = "1--22"
  ),
  haslett1989space = bibentry(
    "article",
    title = "Space-time Modelling with Long-memory Dependence: Assessing Ireland's Wind Power Resource",
    author = "John Haslett and Adrian E Raftery",
    journal = "Journal of the Royal Statistical Society: Series C (Applied Statistics)",
    volume = "38",
    number = "1",
    pages = "1--21",
    year = "1989",
    publisher = "Wiley Online Library"
  ),
  wang2006characteristic = bibentry(
    "article",
    title = "Characteristic-based clustering for time series data",
    author = "Xiaozhe Wang and Kate Smith and Rob Hyndman",
    journal = "Data Mining and Knowledge Discovery",
    volume = "13",
    pages = "335--364",
    year = "2006",
    publisher = "Springer"
  ),
  hyndman2018fpp = bibentry(
    "book",
    title = "Forecasting: principles and practice",
    author = "Rob J Hyndman and George Athanasopoulos",
    edition = "2nd",
    publisher = "OTexts",
    address = "Melbourne, Australia",
    year = "2018",
    url = "https://OTexts.com/fpp2/"
  ),
  hyndman2002state = bibentry(
    "article",
    title = "A state space framework for automatic forecasting using exponential smoothing methods",
    author = "Rob J Hyndman and Anne B Koehler and Ralph D Snyder and Simone Grose",
    journal = "International Journal of Forecasting",
    volume = "18",
    number = "3",
    pages = "439--454",
    year = "2002"
  ),
  hyndman2008admissible = bibentry(
    "article",
    title = "The admissible parameter space for exponential smoothing models",
    author = "Rob J Hyndman and Muhammad Akram and Blyth Archibald",
    journal = "Annals of the Institute of Statistical Mathematics",
    volume = "60",
    number = "2",
    pages = "407--426",
    year = "2008"
  ),
  hyndman2008smoothing = bibentry(
    "book",
    title = "Forecasting with exponential smoothing: the state space approach",
    author = "Rob J Hyndman and Anne B Koehler and J Keith Ord and Ralph D Snyder",
    publisher = "Springer-Verlag",
    year = "2008",
    url = "https://robjhyndman.com/expsmooth"
  ),
  livera2011complex = bibentry(
    "article",
    title = "Forecasting time series with complex seasonal patterns using exponential smoothing",
    author = "Alysha M De Livera and Rob J Hyndman and Ralph D Snyder",
    journal = "Journal of the American Statistical Association",
    volume = "106",
    number = "496",
    pages = "1513--1527",
    year = "2011"
  ),
  blaskowitz2011directional = bibentry(
    "article",
    title = "On economic evaluation of directional forecasts",
    author = "Oliver Blaskowitz and Helmut Herwartz",
    journal = "International Journal of Forecasting",
    volume = "27",
    number = "4",
    pages = "1058--1065",
    year = "2011"
  ),
  box1976 = bibentry(
    "book",
    title = "Time Series Analysis: Forecasting and Control",
    author = "George E P Box and Gwilym M Jenkins",
    edition = "Revised",
    publisher = "Holden-Day",
    address = "San Francisco",
    year = "1976"
  ),
  brockwell1991 = bibentry(
    "book",
    title = "Time Series: Theory and Methods",
    author = "Peter J Brockwell and Richard A Davis",
    edition = "2nd",
    publisher = "Springer",
    address = "New York",
    year = "1991"
  ),
  becker1988news = bibentry(
    "book",
    title = "The New S Language",
    author = "Richard A Becker and John M Chambers and Allan R Wilks",
    publisher = "Chapman and Hall/CRC",
    address = "London",
    year = "1988"
  ),
  campbell1977lynx = bibentry(
    "article",
    title = "A Survey of Statistical Work on the Mackenzie River Series of Annual Canadian Lynx Trappings for the Years 1821-1934 and a New Analysis",
    author = "M J Campbell and A M Walker",
    journal = "Journal of the Royal Statistical Society. Series A (General)",
    volume = "140",
    number = "4",
    pages = "411--431",
    year = "1977",
    doi = "10.2307/2345277"
  ),
  kourentzes2014neural = bibentry(
    "article",
    title = "Neural network ensemble operators for time series forecasting",
    author = "Nikolaos Kourentzes and Devon K. Barrow and Sven F. Crone",
    journal = "Expert Systems with Applications",
    volume = "41",
    number = "9",
    pages = "4235--4244",
    year = "2014",
    doi = "10.1016/j.eswa.2013.12.011"
  ),
  ripley_1996 = bibentry(
    "book",
    doi = "10.1017/cbo9780511812651",
    year = "1996",
    month = "jan",
    publisher = "Cambridge University Press",
    author = "Brian D Ripley",
    title = "Pattern Recognition and Neural Networks"
  ),
  svetunkov2023smooth = bibentry(
    "misc",
    title = "Smooth forecasting with the smooth package in R",
    author = "Ivan Svetunkov",
    year = "2023",
    eprint = "2301.01790",
    archivePrefix = "arXiv",
    primaryClass = "stat.ME",
    url = "https://arxiv.org/abs/2301.01790"
  ),
  svetunkov2023adam = bibentry(
    "book",
    title = "Forecasting and Analytics with the Augmented Dynamic Adaptive Model (ADAM)",
    author = "Ivan Svetunkov",
    edition = "1st",
    publisher = "Chapman and Hall/CRC",
    year = "2023",
    doi = "10.1201/9781003452652",
    url = "https://openforecast.org/adam/"
  ),
  godahewa2021monash = bibentry(
    "article",
    title = "Monash time series forecasting archive",
    author = "Rakshitha Godahewa and Christoph Bergmeir and Geoffrey I Webb and Rob J Hyndman and Pablo Montero-Manso",
    journal = "arXiv preprint arXiv:2105.06643",
    year = "2021"
  ),
  croston1972forecasting = bibentry(
    "article",
    title = "Forecasting and stock control for intermittent demands",
    author = "John D Croston",
    journal = "Journal of the Operational Research Society",
    volume = "23",
    number = "3",
    pages = "289--303",
    year = "1972",
    publisher = "Taylor & Francis"
  ),
  shale2006forecasting = bibentry(
    "article",
    title = "Forecasting for intermittent demand: the estimation of an unbiased average",
    author = "Estelle A Shale and John E Boylan and FR Johnston",
    journal = "Journal of the Operational Research Society",
    volume = "57",
    number = "5",
    pages = "588--592",
    year = "2006",
    publisher = "Taylor & Francis"
  ),
  shenstone2005stochastic = bibentry(
    "article",
    title = "Stochastic models underlying Croston's method for intermittent demand forecasting",
    author = "Lydia Shenstone and Rob J Hyndman",
    journal = "Journal of Forecasting",
    volume = "24",
    number = "6",
    pages = "389--402",
    year = "2005",
    publisher = "Wiley Online Library"
  ),
  syntetos2001bias = bibentry(
    "article",
    title = "On the bias of intermittent demand estimates",
    author = "Aris A Syntetos and John E Boylan",
    journal = "International Journal of Production Economics",
    volume = "71",
    number = "1-3",
    pages = "457--466",
    year = "2001",
    publisher = "Elsevier"
  ),
  assimakopoulos2000theta = bibentry(
    "article",
    title = "The theta model: a decomposition approach to forecasting",
    author = "Vassilis Assimakopoulos and Konstantinos Nikolopoulos",
    journal = "International Journal of Forecasting",
    volume = "16",
    number = "4",
    pages = "521--530",
    year = "2000",
    publisher = "Elsevier"
  ),
  hyndman2003unmasking = bibentry(
    "article",
    title = "Unmasking the Theta method",
    author = "Rob J Hyndman and Baki Billah",
    journal = "International Journal of Forecasting",
    volume = "19",
    number = "2",
    pages = "287--290",
    year = "2003",
    publisher = "Elsevier"
  ),
  hyndman2005local = bibentry(
    "article",
    title = "Local linear forecasts using cubic smoothing splines",
    author = "Rob J Hyndman and Maxwell L King and Ivet Pitrun and Baki Billah",
    journal = "Australian & New Zealand Journal of Statistics",
    volume = "47",
    number = "1",
    pages = "87--99",
    year = "2005",
    publisher = "Wiley Online Library"
  ),
  hyndman2006another = bibentry(
    "article",
    title = "Another look at measures of forecast accuracy",
    author = "Rob J Hyndman and Anne B Koehler",
    journal = "International Journal of Forecasting",
    volume = "22",
    number = "4",
    pages = "679--688",
    year = "2006",
    publisher = "Elsevier"
  ),
  winkler1972scoring = bibentry(
    "article",
    title = "A Decision-Theoretic Approach to Interval Estimation",
    author = "Robert L Winkler",
    journal = "Journal of the American Statistical Association",
    volume = "67",
    number = "337",
    pages = "187--191",
    year = "1972",
    publisher = "Taylor & Francis"
  ),
  makridakis2020m4 = bibentry(
    "article",
    title = "The M4 Competition: 100,000 time series and 61 forecasting methods",
    author = "Spyros Makridakis and Evangelos Spiliotis and Vassilios Assimakopoulos",
    journal = "International Journal of Forecasting",
    volume = "36",
    number = "1",
    pages = "54--74",
    year = "2020",
    publisher = "Elsevier"
  ),
  gneiting2007scoring = bibentry(
    "article",
    title = "Strictly Proper Scoring Rules, Prediction, and Estimation",
    author = "Tilmann Gneiting and Adrian E Raftery",
    journal = "Journal of the American Statistical Association",
    volume = "102",
    number = "477",
    pages = "359--378",
    year = "2007",
    publisher = "Taylor & Francis"
  ),
  koenker1978regression = bibentry(
    "article",
    title = "Regression Quantiles",
    author = "Roger Koenker and Gilbert Bassett",
    journal = "Econometrica",
    volume = "46",
    number = "1",
    pages = "33--50",
    year = "1978",
    publisher = "JSTOR"
  ),
  liboschik2017tscount = bibentry(
    "article",
    title = "tscount: An R Package for Analysis of Count Time Series Following Generalized Linear Models",
    author = "Tobias Liboschik and Konstantinos Fokianos and Roland Fried",
    journal = "Journal of Statistical Software",
    volume = "82",
    number = "5",
    pages = "1--51",
    year = "2017",
    doi = "10.18637/jss.v082.i05"
  ),
  taylor2018forecasting = bibentry(
    "article",
    title = "Forecasting at Scale",
    author = "Sean J. Taylor and Benjamin Letham",
    journal = "The American Statistician",
    volume = "72",
    number = "1",
    pages = "37--45",
    year = "2018",
    publisher = "Taylor & Francis",
    doi = "10.1080/00031305.2017.1380080"
  ),
  cleveland1990stl = bibentry(
    "article",
    title = "STL: A Seasonal-Trend Decomposition Procedure Based on Loess",
    author = "Robert B. Cleveland and William S. Cleveland and Jean E. McRae and Irma Terpenning",
    journal = "Journal of Official Statistics",
    volume = "6",
    number = "1",
    pages = "3--73",
    year = "1990"
  ),
  harvey1989forecasting = bibentry(
    "book",
    title = "Forecasting, Structural Time Series Models and the Kalman Filter",
    author = "Andrew C. Harvey",
    year = "1989",
    publisher = "Cambridge University Press",
    address = "Cambridge"
  ),
  bergmeir2016bagging = bibentry(
    "article",
    title = "Bagging exponential smoothing methods using STL decomposition and Box-Cox transformation",
    author = "Christoph Bergmeir and Rob J Hyndman and Jos\u00e9 M Ben\u00edtez",
    journal = "International Journal of Forecasting",
    volume = "32",
    number = "2",
    pages = "303--312",
    year = "2016",
    doi = "10.1016/j.ijforecast.2015.07.002",
    publisher = "Elsevier"
  ),
  holt2004forecasting = bibentry(
    "article",
    title = "Forecasting seasonals and trends by exponentially weighted moving averages",
    author = "Charles C. Holt",
    journal = "International Journal of Forecasting",
    volume = "20",
    number = "1",
    pages = "5--10",
    year = "2004",
    doi = "10.1016/j.ijforecast.2003.09.015",
    publisher = "Elsevier"
  ),
  winters1960forecasting = bibentry(
    "article",
    title = "Forecasting Sales by Exponentially Weighted Moving Averages",
    author = "Peter R. Winters",
    journal = "Management Science",
    volume = "6",
    number = "3",
    pages = "324--342",
    year = "1960",
    doi = "10.1287/mnsc.6.3.324"
  ),
  smyl2025rlgt = bibentry(
    "manual",
    title = "Rlgt: Bayesian Exponential Smoothing Models with Trend Modifications",
    author = "Slawek Smyl and Christoph Bergmeir and Erwin Wibowo and To Wang Ng and Xueying Long and Alexander Dokumentov and Daniel Schmidt",
    year = "2025",
    note = "R package version 0.2-3",
    url = "https://github.com/cbergmeir/Rlgt"
  )
)
# nolint end
