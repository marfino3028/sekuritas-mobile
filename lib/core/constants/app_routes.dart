class AppRoutes {
  AppRoutes._();

  // Auth
  static const splash = '/';
  static const register = '/register';
  static const otp = '/otp';
  static const createPin = '/create-pin';
  static const confirmPin = '/confirm-pin';
  static const invitationCode = '/invitation-code';

  // Main shell
  static const main = '/main';
  static const home = '/main/home';
  static const portfolio = '/main/portfolio';
  static const explore = '/main/explore';
  static const transaction = '/main/transaction';
  static const profile = '/main/profile';

  // KYC
  static const riskProfile = '/kyc/risk-profile';
  static const riskResult = '/kyc/risk-result';
  static const ktpGuide = '/kyc/ktp-guide';
  static const ktpCapture = '/kyc/ktp-capture';
  static const selfieCapture = '/kyc/selfie-capture';
  static const personalData = '/kyc/personal-data';
  static const bankData = '/kyc/bank-data';
  static const signature = '/kyc/signature';
  static const kycSuccess = '/kyc/success';
}
