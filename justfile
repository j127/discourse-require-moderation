# Clean up junk files
clean:
  find . -name '*.pyc' -exec rm -f {} +
  find . -name '*.pyo' -exec rm -f {} +
  find . -name '*~' -exec rm -f {} +
  find . -name '__pycache__' -exec rm -rf {} +
  find . -name '.DS_Store' -exec rm -f {} +


