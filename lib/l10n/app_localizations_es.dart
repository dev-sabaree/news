// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aplicación de Noticias';

  @override
  String get search => 'Buscar noticias...';

  @override
  String get noArticlesFound => 'No se encontraron artículos';

  @override
  String get noInternet => 'Sin internet — mostrando noticias en caché';

  @override
  String get noInternetConnection => 'Sin conexión a Internet';

  @override
  String get failedToLoad => 'Error al cargar noticias';

  @override
  String get refresh => 'Actualizar';

  @override
  String get readMore => 'Leer artículo completo';

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
  String get noDescription => 'No hay descripción disponible';

  @override
  String get noContent => 'No hay contenido disponible';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get signup => 'Registrarse';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get invalidEmail => 'Ingresa un correo válido';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get invalidPhone => 'Ingresa un número de teléfono válido';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get signupSuccess => '¡Cuenta creada exitosamente!';

  @override
  String get errorInvalidCredentials =>
      'Correo o contraseña incorrectos. Inténtalo de nuevo.';

  @override
  String get errorEmailNotConfirmed =>
      'Por favor verifica tu correo antes de iniciar sesión.';

  @override
  String get errorUserNotFound =>
      'No se encontró ninguna cuenta con este correo.';

  @override
  String get errorTooManyRequests =>
      'Demasiados intentos. Inténtalo más tarde.';

  @override
  String get errorNetworkError => 'Sin conexión a internet. Verifica tu red.';

  @override
  String get errorInvalidEmail =>
      'Por favor ingresa un correo electrónico válido.';

  @override
  String get errorWeakPassword =>
      'La contraseña es débil. Usa al menos 6 caracteres.';

  @override
  String get errorEmailExists =>
      'Ya existe una cuenta con este correo electrónico.';

  @override
  String get errorUnknown => 'Algo salió mal. Por favor inténtalo de nuevo.';
}
