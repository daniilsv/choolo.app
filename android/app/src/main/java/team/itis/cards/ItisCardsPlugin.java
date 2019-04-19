package team.itis.cards;

import android.content.Intent;
import android.net.Uri;
import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Parcelable;
import android.util.Log;

import java.io.IOException;

import io.chirp.connect.ChirpConnect;
import io.chirp.connect.interfaces.ConnectEventListener;
import io.chirp.connect.interfaces.ConnectSetConfigListener;
import io.chirp.connect.models.ChirpError;
import io.chirp.connect.models.ConnectState;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class ItisCardsPlugin implements MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private PluginRegistry.Registrar registrar;
    private EventChannel.EventSink channel = null;

    private final String APP_KEY = "B714C0a6A13bF9551c2cadF5f";
    private final String APP_SECRET = "eB650DD320F08Fdb6ee7DdbfbDdE5afcde1219a77ed3eA142f";
    private ChirpConnect chirpConnect = null;

    private ItisCardsPlugin(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
    }

    public static void registerWith(PluginRegistry.Registrar registrar) {
        ItisCardsPlugin icp = new ItisCardsPlugin(registrar);
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "itis.cards");
        channel.setMethodCallHandler(icp);
        final EventChannel streamChannel = new EventChannel(registrar.messenger(), "itis.cards/stream");
        streamChannel.setStreamHandler(icp);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {

        String method = call.method;
        ChirpError chirpError;
        switch (method) {
            case "getNfcAvailable":
                result.success(getNfcAvailable());
                break;
            case "readNfcIntent":
                result.success(readCardDataFromIntent(registrar.activity().getIntent()));
                break;

            case "startBeepSdk":
                if (chirpConnect == null)
                    initSoundSender();
                chirpError = chirpConnect.start();
                if (chirpError.getCode() > 0) {
                    Log.e("ConnectError: ", chirpError.getMessage());
                }
                result.success(true);
                break;
            case "restartBeepSdk":
                if(chirpConnect == null)
                    initSoundSender();
                else{
                    chirpError = chirpConnect.stop();
                    if (chirpError.getCode() > 0) {
                        Log.e("ConnectError: ", chirpError.getMessage());
                    }
                }
                chirpError = chirpConnect.start();
                if (chirpError.getCode() > 0) {
                    Log.e("ConnectError: ", chirpError.getMessage());
                    return;
                }
                result.success(true);
                break;
            case "stopBeepSdk":
                chirpError = chirpConnect.stop();
                if (chirpError.getCode() > 0) {
                    Log.e("ConnectError: ", chirpError.getMessage());
                }
                result.success(true);
                break;
            case "sendBeepData":
                if (chirpConnect == null)
                    initSoundSender();
                ChirpError e = chirpConnect.start();
                send((String) call.arguments);
                result.success(true);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    private int getNfcAvailable() {
        NfcAdapter nfcAdapter = NfcAdapter.getDefaultAdapter(registrar.context());

        if (nfcAdapter == null) {
            return 1;
        } else if (!nfcAdapter.isEnabled()) {
            return 2;
        } else {
            return 0;
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink result) {
        channel = result;
    }

    @Override
    public void onCancel(Object args) {

    }

    private String readCardDataFromIntent(Intent intent) {
        String action = intent.getAction();
        if (NfcAdapter.ACTION_TAG_DISCOVERED.equals(action)
                || NfcAdapter.ACTION_TECH_DISCOVERED.equals(action)
                || NfcAdapter.ACTION_NDEF_DISCOVERED.equals(action)) {
            Parcelable[] rawMsgs = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
            if (rawMsgs == null)
                return null;
            for (Parcelable rawMsg : rawMsgs) {
                for (NdefRecord rec : ((NdefMessage) rawMsg).getRecords()) {
                    if (new String(rec.getType()).equals("itis/cards"))
                        return new String(rec.getPayload());
                }
            }

        } else if (Intent.ACTION_VIEW.equals(action)) {
            Uri data = intent.getData();
            if (data == null)
                return null;

            if (data.toString().startsWith("http")) {
                String parts[] = data.toString().split("itis.cards/");
                if (parts.length == 2)
                    return parts[1];
            }
        }
        return null;
    }

    public ConnectEventListener connectEventListener = new ConnectEventListener() {

        @Override
        public void onSending(byte[] data, byte chChannel) {
            String hexData = "null";
            if (data != null) {
                hexData = chirpConnect.payloadToHexString(data);
            }
            if (channel != null) channel.success("bsng" + hexData);
            Log.v("connectdemoapp", "ConnectCallback: onSending: " + hexData + " on channel: " + chChannel);
        }

        @Override
        public void onSent(byte[] data, byte chChannel) {
            String hexData = "null";
            if (data != null) {
                hexData = chirpConnect.payloadToHexString(data);
            }
            if (channel != null) channel.success("bsnt" + hexData);
            Log.v("connectdemoapp", "ConnectCallback: onSent: " + hexData + " on channel: " + chChannel);
        }

        @Override
        public void onReceiving(byte chChannel) {
            if (channel != null) channel.success("brvg-");
            Log.v("connectdemoapp", "ConnectCallback: onReceiving on channel: " + chChannel);
        }

        @Override
        public void onReceived(byte[] data, byte chChannel) {
            String hexData = "null";
            if (data != null) {
                hexData = chirpConnect.payloadToHexString(data);
            }
            try {
                if (channel != null) channel.success("brvd" + hexToString(hexData));
            } catch (Exception ignored) {
                if (channel != null) channel.success("brvdfail");
            }
            Log.v("connectdemoapp", "ConnectCallback: onReceived: " + hexData + " on channel: " + chChannel);
        }


        @Override
        public void onStateChanged(byte oldState, byte newState) {
            ConnectState state = ConnectState.createConnectState(newState);
            if (channel == null) return;
            if (state == ConnectState.ConnectNotCreated) {
                channel.success("bsts" + "NotCreated");
            } else if (state == ConnectState.AudioStateStopped) {
                channel.success("bsts" + "Stopped");
            } else if (state == ConnectState.AudioStatePaused) {
                channel.success("bsts" + "Paused");
            } else if (state == ConnectState.AudioStateRunning) {
                channel.success("bsts" + "Running");
            } else if (state == ConnectState.AudioStateSending) {
                channel.success("bsts" + "Sending");
            } else if (state == ConnectState.AudioStateReceiving) {
                channel.success("bsts" + "Receiving");
            } else {
                channel.success("bsts" + newState);
            }
        }

        @Override
        public void onSystemVolumeChanged(int i, int i1) {

        }

    };
    
    private static byte[] stringToByteArray(String s) {
        return s.getBytes();
    }

    private static String hexToString(String txtInHex) {
        byte[] txtInByte = new byte[txtInHex.length() / 2];
        int j = 0;
        for (int i = 0; i < txtInHex.length(); i += 2) {
            txtInByte[j++] = Byte.parseByte(txtInHex.substring(i, i + 2), 16);
        }
        return new String(txtInByte);
    }

    private void initSoundSender() {
        chirpConnect = new ChirpConnect(registrar.activeContext(), APP_KEY, APP_SECRET);
        chirpConnect.setConfig(registrar.activity().getResources().getString(R.string.CHIRP_LICENSE), new ConnectSetConfigListener() {

            @Override
            public void onSuccess() {
                chirpConnect.setListener(connectEventListener);
            }

            @Override
            public void onError(ChirpError setConfigError) {
                Log.e("setConfigError", setConfigError.getMessage());
            }
        });
    }

    public void send(String message) {
        byte[] payload = stringToByteArray(message);
        System.out.println(chirpConnect.getChannelCount());
        long maxSize = chirpConnect.getMaxPayloadLength();
        if (maxSize < payload.length) {
            Log.e("ConnectError: ", "Invalid Payload");
            return;
        }
        chirpConnect.send(payload);
    }

}
