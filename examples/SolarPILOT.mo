class Solarpilot
  extends ExternalObject;
  function constructor
    output Solarpilot test;
    external "C" test = sp_data_create() annotation(Library = "solarpilot", Include = "#include \"CoPilot_API.h\"");
  end constructor;
  
  function destructor
    input Solarpilot test;
    output Integer data_was_free;
  external "C" data_was_free = sp_data_free(test) annotation(Library = "solarpilot", Include = "#include \"CoPilot_API.h\"");
  end destructor;
end Solarpilot;
