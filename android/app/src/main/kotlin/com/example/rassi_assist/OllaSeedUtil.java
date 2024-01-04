package com.example.rassi_assist;

import android.util.Base64;
import android.util.Log;

import java.net.URLEncoder;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESedeKeySpec;

public class OllaSeedUtil {
    private static final String TAG = "[SeedUtil] ";
	private static final String algorithm = "DESede";
	private static final String desKey = "|olla.com|thinkpool.com|";
	private static final String encCharset = "utf-8";
	private static Cipher cipher = null;
	private static SecretKey secretKey = null;

	public OllaSeedUtil() throws Exception {
	}

	public static String encode(String val) throws Exception {
		cipher = Cipher.getInstance(algorithm);
		DESedeKeySpec desKeySpec = new DESedeKeySpec(desKey.getBytes());
		SecretKeyFactory keyFactory = SecretKeyFactory.getInstance(algorithm);
		secretKey = keyFactory.generateSecret(desKeySpec);

		cipher.init(Cipher.ENCRYPT_MODE, secretKey);
		return Base64.encodeToString(cipher.doFinal(val.getBytes(encCharset)), Base64.DEFAULT);
	}

	public static String setSeedEncodeData(String data) {
		String ret = "";
		try {
			Log.w(TAG, "before Inode data : " + data);
			Log.w(TAG, "data : " + encode(data));
			ret = URLEncoder.encode(encode(data), "utf-8");
		} catch (Exception e) {
			return ret;
		}

		return ret;
	}
}
