/// Native method nomlari
enum Methods {
  /// Firebase options initialize
  initOptions('init_options'),

  /// save language
  saveLanguage('save_language'),

  /// Channel yaratish
  createChannel('create_channel'),

  /// Notification ko'rsatish
  showNotification('show_notification'),

  /// Channel o'chirish
  deleteChannel('delete_channel'),

  /// Channel mavjudligini tekshirish
  channelExists('channel_exists'),

  /// Barcha channel'larni olish
  getAllChannels('get_all_channels'),

  /// Notification cancel qilish
  cancelNotification('cancel_notification'),

  /// Barcha notification'larni cancel qilish
  cancelAllNotifications('cancel_all_notifications');

  const Methods(this.name);

  /// Native method nomi
  final String name;
}