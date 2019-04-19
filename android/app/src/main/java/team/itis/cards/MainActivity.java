package team.itis.cards;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    ItisCardsPlugin.registerWith(this.registrarFor(ItisCardsPlugin.class.getName()));
    GeneratedPluginRegistrant.registerWith(this);
  }
}
