rule adapt_metadata:
    input:
        metadata = config["metadata"]
    output:
        expand(os.path.join(code_dir, "metadata_{col}.tsv"), col = META_COLS)
    run:
        with open(input.metadata, "r", newline = '') as f:
          reader = csv.reader(f, delimiter = '\t')
          headers = next(reader)
          for column_name in headers[1:]:
            output_file = f"metadata_{column_name}.tsv"
            unique_values = set()
            for row in reader:
              unique_values.add(row[headers.index(column_name)])
            f.seek(0)
            next(reader)
            with open(output_file, "w", newline='') as out_f:
              writer = csv.writer(out_f, delimiter='\t')
              writer.writerow(["ID"])
              writer.writerows([[value] for value in unique_values])