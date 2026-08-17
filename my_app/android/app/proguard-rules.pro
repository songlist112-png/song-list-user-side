# Room creates generated database implementations through reflection.
# Keep their constructors when R8 optimizes release builds.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
