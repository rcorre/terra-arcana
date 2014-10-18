module dau.util.config;

import std.conv;
import std.algorithm;
import std.string;
import dau.allegro;

struct ConfigData {
  string[string][string] entries;
  string[string] globals;
}

ConfigData loadConfigFile(string path) {
  ConfigData data;
  ALLEGRO_CONFIG* cfgFile = al_load_config_file(toStringz(path));
  assert(cfgFile, "could not load config file " ~ path);
  ALLEGRO_CONFIG_SECTION* sectionIterator;
  for (auto section = al_get_first_config_section(cfgFile, &sectionIterator);
            section !is null;
            section = al_get_next_config_section(&sectionIterator))
  {
    ALLEGRO_CONFIG_ENTRY* entryIterator;
    for (auto entry = al_get_first_config_entry(cfgFile, section, &entryIterator);
              entry !is null;
              entry = al_get_next_config_entry(&entryIterator))
    {
      auto value = to!string(al_get_config_value(cfgFile, section, entry));
      auto entryName = to!string(entry);
      auto sectionName = to!string(section);
      if (sectionName == "") { // global section
        data.globals[entryName] = value;
      }
      else {
        data.entries[sectionName][entryName] = value;
      }
    }
  }
  return data;
}

ALLEGRO_COLOR parseColor(string spec) {
  auto vals = map!((s) => to!ubyte(strip(s)))(split(spec, ','));
  assert(vals.length == 3 || vals.length == 4, spec ~ " is not a valid color spec. try r,g,b or r,g,b,a");
  return (vals.length == 3) ? al_map_rgb(vals[0], vals[1], vals[2]) : al_map_rgba(vals[0], vals[1], vals[2], vals[3]);
}
