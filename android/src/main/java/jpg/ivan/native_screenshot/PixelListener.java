package com.dsquare90.native_screenshot_ext;

import android.annotation.SuppressLint;
import android.view.PixelCopy;

@SuppressLint("NewApi")
public class PixelListener implements PixelCopy.OnPixelCopyFinishedListener {
	private boolean error = false;

	public boolean hasError() {
		return this.error;
	} // hasError()

	@Override
	public void onPixelCopyFinished(int result) {
		if(result != PixelCopy.SUCCESS) {
			this.error = true;

			return;
		} // if error

		this.error = false;
	} // OnPixelCopyFinishedListener()
} // PixelListener
