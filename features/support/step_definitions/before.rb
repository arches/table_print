Before do
  Sandbox.cleanup!
  TablePrint::Config.singleton.clear(:capitalize_headers)
  TablePrint::Config.singleton.clear(:separator)
end
