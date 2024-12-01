class CountryCity {
  final String country;
  final List<String> cities;

  CountryCity({
    required this.country,
    required this.cities,
  });

  factory CountryCity.fromJson(Map<String, dynamic> json) {
    return CountryCity(
      country: json['country'],
      cities: List<String>.from(json['cities']),
    );
  }
}

class CountryCityResponse {
  final bool error;
  final String msg;
  final List<CountryCity> data;

  CountryCityResponse({
    required this.error,
    required this.msg,
    required this.data,
  });

  factory CountryCityResponse.fromJson(Map<String, dynamic> json) {
    return CountryCityResponse(
      error: json['error'],
      msg: json['msg'],
      data: List<CountryCity>.from(
        json['data'].map((x) => CountryCity.fromJson(x)),
      ),
    );
  }
}
