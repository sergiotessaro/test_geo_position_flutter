const String geoPosicTable = '''
        CREATE TABLE IF NOT EXISTS location (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT,
          hora TEXT,
          latitude TEXT,
          longitude TEXT
        );
''';