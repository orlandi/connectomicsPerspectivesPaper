#!/usr/bin/env python

# Authors: Aaron Qiu <zqiu@ulg.ac.be>,
#          Antonio Sutera <a.sutera@ulg.ac.be>,
#          Arnaud Joly <a.joly@ulg.ac.be>,
#          Gilles Louppe <g.louppe@ulg.ac.be>,
#          Vincent Francois <v.francois@ulg.ac.be>
#
# License: BSD 3 clause

from __future__ import division, print_function, absolute_import

import os
import argparse
from itertools import product
from pprint import pprint

import numpy as np

from PCA import make_simple_inference, make_tuned_inference
from directivity import make_prediction_directivity
from hidden import kill

# Cache accelerator may be removed to save disk space
#from clusterlib.storage import sqlite3_dumps

WORKING_DIR = os.path.join(os.environ["HOME"],
                           "research/connectomicsPCVpaper/verifications/aaagv/paper-connectomics/crowdsource/code")


#def get_sqlite3_path():
#    return os.path.join(WORKING_DIR, "experiment.sqlite3")


def make_hash(args):
    """Generate a unique hash for the experience"""
    if "killing" in args:
        return "%(network)s-m=%(method)s-d=%(directivity)s-k=%(killing)s" % args

    else:
        return "%(network)s-m=%(method)s-d=%(directivity)s" % args

def parse_arguments(args=None):
    parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS)
    parser.add_argument('-f', '--fluorescence', type=str, required=True,
                        help='Path to the fluorescence file')
    # parser.add_argument('-p', '--position', type=str, required=False,
    #                     help='Path to the network position file')
    parser.add_argument('-o', '--output_dir', type=str,
                        help='Path of the prediction file if wanted')

    parser.add_argument('-n', '--network', type=str, required=True,
                        help='Network name')
    parser.add_argument('-m', '--method', type=str, required=True,
                        default='simple', help='Simplified or tuned method?',
                        choices=["simple", "tuned"])
    parser.add_argument('-d', '--directivity', type=int, required=False,
                        default=0, choices=[0, 1],
                        help='Consider information about directivity?')
    parser.add_argument('-k', '--killing', type=int, required=False,
                        choices=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                        help='Should we "kill" some neurons?')
    return vars(parser.parse_args(args))

if __name__ == "__main__":
    # Process arguments
    args = parse_arguments()
    pprint(args)
    job_hash = make_hash(args)

    name = args["network"]

    # Loading data
    print('Loading data...')
    X = np.loadtxt(args["fluorescence"], delimiter=",")
    X = np.asfortranarray(X, dtype=np.float32)
    # pos = np.loadtxt(args["position"], delimiter=",")

    # Should we remove some neurons?
    if "killing" in args:
        if args["network"] in ["normal-3",
                               "normal-4"]:
            X = kill(X, args["network"], args["killing"])
        else:
            raise ValueError("No killing specified for %s" % args["network"])

    # Producing the prediction matrix
    if args["method"] == 'tuned':
        y_pca = make_tuned_inference(X)
    else:
        y_pca = make_simple_inference(X)

    if args["directivity"]:
        print('Using information about directivity...')
        y_directivity = make_prediction_directivity(X)
        # Perform stacking
        score = 0.997 * y_pca + 0.003 * y_directivity
    else:
        score = y_pca

    # Save data
    if "output_dir" in args:
        if not os.path.exists(args["output_dir"]):
            os.makedirs(args["output_dir"])

        outname = os.path.join(args["output_dir"], "%s.csv" % job_hash)

        # Generate the submission file ##
        with open(outname, 'w') as fname:
            fname.write("NET_neuronI_neuronJ,Strength\n")

            for i, j in product(range(score.shape[0]), range(score.shape[1])):
                line = "{0}_{1}_{2},{3}\n".format(name, i + 1, j + 1,
                                                  score[i, j])
                fname.write(line)

        print("Infered connectivity score is saved at %s" % outname)

    # Indicate the job is finished
    print("job_hash %s" % job_hash)
    #sqlite3_dumps({job_hash: "JOB DONE"}, get_sqlite3_path())
