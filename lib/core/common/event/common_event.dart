
import 'event_bus.dart';

///公共eventBus 事件通知
final EventBus eventBus = EventBus();


///暂停video事件
class PauseVideoEvent{
  const PauseVideoEvent();
}