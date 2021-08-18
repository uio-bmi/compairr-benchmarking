import argparse
from pathlib import Path
import pandas as pd
import re
import sys
import os
import errno


def parse_folder(input_path, number_of_repertoires):
    descr_dict = {"n_rep": [],
                  "n_seq": [],
                  "d": [],
                  "t": [],
                  "i": [],
                  "repetition": []}

    time_dict = {"Reading sequences": [],
                 "Indexing": [],
                 "Sorting": [],
                 "Computing hashes": [],
                 "Hashing sequences": [],
                 "Analysing": [],
                 "Writing results": []}


    for filename in input_path.glob(f"{number_of_repertoires}*.log"):
        with open(filename) as file:
            filename_parts = filename.stem.split("_")

            descr_dict["n_rep"].append(filename_parts[0])
            descr_dict["n_seq"].append(filename_parts[1])
            descr_dict["d"].append(filename_parts[2])
            descr_dict["t"].append(filename_parts[3])
            descr_dict["repetition"].append(filename_parts[-1])

            i = True if len(filename_parts) == 6 and filename_parts[4] == "i" else False
            descr_dict["i"].append(i)

            for line in file:
                for step in time_dict.keys():
                    if line.startswith(step) and "100%" in line:
                        matches = re.search("\((\d+)s\)", line)
                        time_dict[step].append(int(matches.groups()[0]))

    content_dict = {**descr_dict}
    content_dict["Reading input"] = time_dict["Reading sequences"]
    content_dict["Analysing"] = time_dict["Analysing"]
    content_dict["Writing results"] = time_dict["Writing results"]
    content_dict["Indexing, sorting\nand hashing"] = [time_dict["Indexing"][i] +
                                                     time_dict["Sorting"][i] +
                                                     time_dict["Computing hashes"][i] +
                                                     time_dict["Hashing sequences"][i]
                                                     for i in range(len(time_dict["Reading sequences"]))]

    df = pd.DataFrame(content_dict)
    df_melted = pd.melt(df, id_vars=descr_dict.keys(), value_vars=["Reading input", "Analysing", "Writing results", "Indexing, sorting\nand hashing"])

    df_melted["n_repetitions"] = 1

    result = df_melted.groupby(["n_rep", "n_seq", "d", "t", "i", "variable"], as_index=False).agg({"value": ["mean", "min", "max"],
                                                                                          "n_repetitions": ["sum"]})


    result.columns = ["".join(a) for a in result.columns.to_flat_index()]

    return result


def build_output_filepath(file_path):
    folder_path = file_path.parent

    if not folder_path.is_dir():
        try:
            os.makedirs(folder_path)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise


def parse_commandline_arguments(args):
    parser = argparse.ArgumentParser(description="Script for converting CompAIRR log files to a tabular format describing the duration of each analysis step.")

    parser.add_argument("-i", "--input_path", default="compairr_log/", help="Input folder for CompAIRR log files. The default value is 'compairr_log/'.")
    parser.add_argument("-o", "--output_path", default="aggregated_results/compairr_time_parts.tsv", help="Output file for placing the parsed results. The default value is 'aggregated_results/compairr_time_parts.tsv'.")

    parser.add_argument("-n", "--number_of_repertoires", default="1e5", help="The number of repertoires. Only the files with this value as their prefix in the input_path will be included. The default value is '1e5'.")

    return parser.parse_args()


def main(args):
    parsed_args = parse_commandline_arguments(args)
    output_path = Path(parsed_args.output_path)
    build_output_filepath(output_path)

    result = parse_folder(Path(parsed_args.input_path),
                 parsed_args.number_of_repertoires)

    result.to_csv(output_path, sep="\t", index=False)


if __name__ == "__main__":
    main(sys.argv)
