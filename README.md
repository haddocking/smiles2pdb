# `smiles2pdb`

`smiles2pdb` is a small command-line tool to convert SMILES string into PDB
files and optionally generate different conformations of the small molecules.

## Why C++?

This tool uses [RDKit](https://www.rdkit.org) libraries and
[according to their own documentation](https://www.rdkit.org/docs/GettingStartedInC%2B%2B.html#should-you-use-c-or-python)
most functionalities of the C++ libraries can be used via the Python API.

The main purpose of this tool here is to be a component of the
[WeNMR service portal](https://wenmr.science.uu.nl) to handle the generation
of PDB files and for that we need to have a small and portable executable.

By using the C++ libraries directly, we can create a statically compiled binary
with no system dependencies that can be executed anywhere.

## Usage

```bash
$ smiles2pdb
Usage: smiles2pdb <SMILES_string> <output_file.pdb> [num_conformers]
  num_conformers: Number of conformers to generate (default: 1)
```

For example:

```bash
smiles2pdb "Cc1c(nc2ccc(F)cc2c1C(O)=O)c3ccc(cc3)c4ccccc4" 1D3G_BRE.pdb 10
```

The resulting `1D3G_BRE.pdb` will be a _multi-model_ ensemble containing 10
different conformations.

## TODO

- Tune RMSD cutoff between conformations
- Add support for [`SELFIES`](https://github.com/aspuru-guzik-group/selfies)

## Compilation

Compiling this tool as a static binary is non-trivial since it requires several
system packages and a from source installation of RDKit.

To facilitate the compilation we have provided a Dockerfile that acts a builder.

Compile the tool inside the container with:

```bash
docker build -t builder .
```

Copy the compiled binary to the current working directory with

```bash
docker run \
  --rm \
  -u $(id -u):$(id -g) \
  -v $(pwd):/output \
  builder \
  cp /app/build/smiles2pdb /output/
```

Execute it:

```bash
./smiles2pdb
```
