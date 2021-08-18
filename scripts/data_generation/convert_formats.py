#!/usr/bin/python3


import sys
import argparse
import errno
import os
from pathlib import Path
import pandas as pd


def convert_immunarch(input_folder, output_folder, max_i):
    metadata_dict = {"Sample": []}

    i = 0

    for filename in input_folder.glob("*.tsv"):
        i += 1
        print(f"{i}/{max_i}")
        df = pd.read_csv(filename, sep="\t", iterator=False, dtype=str, header=None)
        df.columns = ["CDR3.nt", "CDR3.aa", "V.name", "J.name"]
        df["D.name"] = "NA"
        df["Clones"] = 1
        df["Proportion"] = 1 / len(df)
        df["V.end"] = "NA"
        df["D.start"] = "NA"
        df["D.end"] = "NA"

        df = df[
            ["Clones", "Proportion", "CDR3.nt", "CDR3.aa", "V.name", "D.name", "J.name", "V.end", "D.start", "D.end"]]

        output_filename = output_folder / filename.name
        df.to_csv(output_filename, sep="\t", index=False)

        metadata_dict["Sample"].append(output_filename.stem)

        if i >= max_i:
            break

    metadata_df = pd.DataFrame(metadata_dict)
    metadata_df.to_csv(output_folder / "metadata.txt", sep="\t", index=False)


def convert_vdjtools(input_folder, output_folder, max_i):
    metadata_dict = {"#file.name": [], "sample.id": []}

    i = 0

    for filename in input_folder.glob("*.tsv"):
        i += 1
        print(f"{i}/{max_i}")
        df = pd.read_csv(filename, sep="\t", iterator=False, dtype=str, header=None)
        df.columns = ["CDR3nt", "CDR3aa", "V", "J"]
        df["D"] = "."
        df["count"] = 1
        df["frequency"] = 1 / len(df)

        df = df[["count", "frequency", "CDR3nt", "CDR3aa", "V", "D", "J"]]

        output_filename = output_folder / filename.name
        df.to_csv(output_filename, sep="\t", index=False)

        metadata_dict["#file.name"].append(str(output_filename))
        metadata_dict["sample.id"].append(output_filename.stem)

        if i >= max_i:
            break

    metadata_df = pd.DataFrame(metadata_dict)
    metadata_df.to_csv(output_folder / "metadata.txt", sep="\t", index=False)


def convert_immuneref(input_folder, output_folder,  max_i):

    i = 0

    for filename in input_folder.glob("*.tsv"):
        i += 1
        print(f"{i}/{max_i}")
        df = pd.read_csv(filename, sep="\t", iterator=False, dtype=str, header=None)
        df.columns = ["junction", "junction_aa", "v_call", "j_call"]
        df["sequence_aa"] = ""
        df["sequence"] = ""
        df["d_call"] = ""
        df["freqs"] = 1 / len(df)

        df = df[["sequence_aa", "sequence", "junction_aa", "junction", "freqs", "v_call", "d_call", "j_call"]]

        output_filename = output_folder / filename.name
        df.to_csv(output_filename, sep="\t", index=False)

        if i >= max_i:
            break


def convert_compairr(input_folder, output_folder, max_i, size):
    output_filename = output_folder / f"repertoires_{size}_{max_i}.tsv"

    with open(output_filename, "w") as file:
        file.write("junction_aa\tduplicate_count\tv_call\tj_call\trepertoire_id\n")

    i = 0

    for filename in input_folder.glob("*.tsv"):
        i += 1
        print(f"{i}/{max_i}")
        df = pd.read_csv(filename, sep="\t", iterator=False, dtype=str, header=None)
        df.columns = ["junction", "junction_aa", "v_call", "j_call"]
        df["duplicate_count"] = 1
        df["repertoire_id"] = filename.stem

        df = df[["junction_aa", "duplicate_count", "v_call", "j_call", "repertoire_id"]]

        df.to_csv(output_filename, sep="\t", index=False, header=None, mode='a')

        if i >= max_i:
            break


def convert(input_folder, output_folder, n_rep, n_seq, format):
    input_folder = Path(input_folder) / n_seq
    output_folder = Path(output_folder) / f"{format}_data/{n_seq}/{n_rep}/"

    try:
        os.makedirs(output_folder)
    except OSError as e:
        if e.errno != errno.EEXIST:
            print(f"path {output_folder} already exists!")
            raise

    print(f"starting conversion:\n- input: {input_folder}\n- output: {output_folder}")

    if format == "vdjtools":
        convert_vdjtools(input_folder, output_folder, max_i=n_rep)
    elif format == "immunarch":
        convert_immunarch(input_folder, output_folder, max_i=n_rep)
    elif format == "immuneref":
        convert_immuneref(input_folder, output_folder, max_i=n_rep)
    elif format == "compairr":
        convert_compairr(input_folder, output_folder, max_i=n_rep, size=n_seq)

    print(f"Successfully created output files at: {output_folder}")


def parse_commandline_arguments(args):
    parser = argparse.ArgumentParser(description="Script for converting OLGA-generated repertoires to CompAIRR, VDJtools, immunarch and immuneREF input formats.")

    parser.add_argument("-i", "--input_path", required=True, help="Input folder for OLGA files. This folder must contain subfolders representing the repertoire sizes (e.g., '1e3', '1e4', '1e5'...).")
    parser.add_argument("-o", "--output_path", required=True, help="Output folder for placing the benchmarking results. Subfolders will be created.")


    parser.add_argument("-f", "--output_format",  nargs="+", required=True, choices=["compairr", "vdjtools", "immunarch", "immuneref"], help="Which output format(s) to use.")
    parser.add_argument("-n", "--number_of_repertoires", type=int, nargs="+", required=True, help="Amount of repertoires per output dataset. Make sure that the number of repertoires specified here is the same or smaller than the number of OLGA files in the input folder(s).")
    parser.add_argument("-s", "--repertoire_size", nargs="+", required=True, help="Amount of sequences per repertoire. This will be used to identify the input sub-folder(s).")

    return parser.parse_args()


def main(args):
    parsed_args = parse_commandline_arguments(args)

    print("Start converting formats")
    for n_sequences in parsed_args.repertoire_size:
        for n_repertoires in parsed_args.number_of_repertoires:
            for format in parsed_args.output_format:
                convert(parsed_args.input_path, parsed_args.output_path, n_repertoires, n_sequences, format)

    print("All conversions done")


if __name__ == "__main__":
    main(sys.argv)
