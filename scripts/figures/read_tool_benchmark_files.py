from pathlib import Path
import pandas as pd
import argparse
import os
import errno
import sys


def convert_elapsed_to_seconds(elapsed_str):
    time = 0

    split_time = elapsed_str.split(":")

    time += float(split_time[-1])

    if len(split_time) > 1:
        time += float(split_time[-2]) * 60
    if len(split_time) > 2:
        time += float(split_time[-3]) * 60 * 60
    if len(split_time) > 3:
        raise ValueError(f"Invalid: {elapsed_str}")

    return time


def parse_folder(input_path):
    input_folders = input_path.glob("[a-z]*")

    content_dict = {"tool": [],
                    "full_tool_name": [],
                    "n_rep": [],
                    "n_seq": [],
                    "d": [],
                    "t": [],
                    "i": [],
                    "exitcode": [],
                    "user": [],
                    "system": [],
                    "elapsed": [],
                    "maxrss": [],
                    "avgtext": [],
                    "avgdata": [],
                    "CPU": [],
                    "inputs": [],
                    "outputs": [],
                    "major": [],
                    "minor": [],
                    "swaps": [],
                    "repetition": []}



    for input_folder in input_folders:
        for filename in input_folder.glob("*.txt"):
            repetition = 0
            filename_parts = filename.stem.split("_")

            found_content = False

            with open(filename) as file:
                for line in file:
                    if line.startswith("#"):
                        repetition += 1

                    if line.startswith("exitcode"):
                        found_content = True

                    if found_content:
                        key, value = line.strip().split()
                        content_dict[key].append(value)

                    if line.startswith("swaps"):
                        found_content = False

                        content_dict["tool"].append(input_folder.name)
                        content_dict["n_rep"].append(filename_parts[0])
                        content_dict["n_seq"].append(filename_parts[1])
                        content_dict["repetition"].append(repetition)

                        if input_folder.name == "compairr":
                            content_dict["full_tool_name"].append(input_folder.name + "-" + filename_parts[3])
                            content_dict["d"].append(filename_parts[2])
                            content_dict["t"].append(filename_parts[3])
                            i = True if len(filename_parts) == 5 and filename_parts[4] == "i" else False
                            content_dict["i"].append(i)
                        else:
                            content_dict["full_tool_name"].append(input_folder.name)
                            content_dict["d"].append("")
                            content_dict["t"].append("")
                            content_dict["i"].append("")



    df = pd.DataFrame(content_dict)
    df["elapsed_seconds"] = [convert_elapsed_to_seconds(el_str) for el_str in df["elapsed"]]


    df["exitcode"] = pd.to_numeric(df["exitcode"])
    df["maxrss"] = pd.to_numeric(df["maxrss"])
    df["n_repetitions"] = 1

    result = df.groupby(["tool", "full_tool_name", "n_rep", "n_seq", "d", "t", "i"], as_index=False).agg({"exitcode": ["max"],
                                                                                          "elapsed_seconds": ["mean", "min", "max"],
                                                                                          "maxrss": ["mean", "min", "max"],
                                                                                          "n_repetitions": ["sum"]})#.reset_index()

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

    parser.add_argument("-i", "--input_path", default="benchmark/", help="Input folder for benchmark result files. The folder is expected to contain sub-folders for each benchmarked tool. The default value is 'benchmark/'.")
    parser.add_argument("-o", "--output_path", default="aggregated_results/tool_stats_agg.tsv", help="Output file for placing the parsed results. The default value is 'aggregated_results/tool_stats_agg.tsv'.")

    return parser.parse_args()


def main(args):
    parsed_args = parse_commandline_arguments(args)
    output_path = Path(parsed_args.output_path)
    build_output_filepath(output_path)

    result = parse_folder(Path(parsed_args.input_path))

    result.to_csv(output_path, sep="\t", index=False)


if __name__ == "__main__":
    main(sys.argv)