function get_sp_version
  input Solarpilot test;
  output String version; 
  external "C" version = sp_version(test) annotation(Library = "solarpilot", Include = "#include \"CoPilot_API.h\"");
end get_sp_version;
