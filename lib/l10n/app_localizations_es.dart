// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aplicacion de Noticias';

  @override
  String get appTagline => 'Mantente informado, mantente adelante';

  @override
  String get search => 'Buscar noticias...';

  @override
  String get noArticlesFound => 'No se encontraron articulos';

  @override
  String get noInternet => 'Sin internet - mostrando noticias en cache';

  @override
  String get noInternetConnection => 'Sin conexion a Internet';

  @override
  String get failedToLoad => 'Error al cargar noticias';

  @override
  String get refresh => 'Actualizar';

  @override
  String get readMore => 'Leer articulo completo';

  @override
  String get author => 'Autor';

  @override
  String get publishedAt => 'Publicado el';

  @override
  String get source => 'Fuente';

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get unknownSource => 'Fuente desconocida';

  @override
  String get noDescription => 'No hay descripcion disponible';

  @override
  String get noContent => 'No hay contenido disponible';

  @override
  String get tryDifferentKeywords => 'Intenta buscar con otras palabras clave';

  @override
  String get clearSearch => 'Borrar busqueda';

  @override
  String get login => 'Iniciar sesion';

  @override
  String get loginSubtitle =>
      'Bienvenido de nuevo. Inicia sesion para continuar';

  @override
  String get signup => 'Registrarse';

  @override
  String get signupSubtitle => 'Crea tu cuenta para comenzar';

  @override
  String get email => 'Correo electronico';

  @override
  String get password => 'Contrasena';

  @override
  String get confirmPassword => 'Confirmar contrasena';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get phoneNumber => 'Numero de telefono';

  @override
  String get logout => 'Cerrar sesion';

  @override
  String get signedInAs => 'Sesion iniciada como';

  @override
  String get alreadyHaveAccount => 'Ya tienes una cuenta?';

  @override
  String get dontHaveAccount => 'No tienes una cuenta?';

  @override
  String get invalidEmail => 'Ingresa un correo valido';

  @override
  String get passwordTooShort =>
      'La contrasena debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contrasenas no coinciden';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get invalidPhone => 'Ingresa un numero de telefono valido';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Ingles';

  @override
  String get spanish => 'Espanol';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get signupSuccess => 'Cuenta creada exitosamente!';

  @override
  String get errorInvalidCredentials =>
      'Correo o contrasena incorrectos. Intentalo de nuevo.';

  @override
  String get errorEmailNotConfirmed =>
      'Por favor verifica tu correo antes de iniciar sesion.';

  @override
  String get errorUserNotFound =>
      'No se encontro ninguna cuenta con este correo.';

  @override
  String get errorTooManyRequests =>
      'Demasiados intentos. Intentalo mas tarde.';

  @override
  String get errorNetworkError => 'Sin conexion a internet. Verifica tu red.';

  @override
  String get errorInvalidEmail =>
      'Por favor ingresa un correo electronico valido.';

  @override
  String get errorWeakPassword =>
      'La contrasena es debil. Usa al menos 6 caracteres.';

  @override
  String get errorEmailExists =>
      'Ya existe una cuenta con este correo electronico.';

  @override
  String get errorUnknown => 'Algo salio mal. Por favor intentalo de nuevo.';
}
