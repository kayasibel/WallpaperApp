package com.anime.theme.wallpaper

class TransparentIconActivity : android.app.Activity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Bu aktivite sadece bir "maske" görevi görür, 
        // açıldığı anda kendini kapatır ve hedefi başlatır (zaten intent içinde hedef var)
        finish()
    }
}
