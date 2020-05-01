enum Language { DE, EN, ES, FR }

class LanguageCodeHandler {
  static Language parseLanguageCode(String code) {
    code = code.toUpperCase();
    switch (code) {
      case "DE":
        return Language.DE;
        break;
      case "EN":
        return Language.EN;
        break;
      case "ES":
        return Language.ES;
        break;
      case "FR":
        return Language.FR;
        break;
      default:
        throw Error();
    }
  }
}
