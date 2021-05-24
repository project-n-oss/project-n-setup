from functools import reduce, partial
from typing import List, Tuple

# Run this to generate the platform-specific scripts

# to_replace is a list of tuples of the form pattern, infile.
# Reads general_infile; replaces each pattern with the contents of its corresponding infile; writes to outfile
def compile(general_infile: str, outfile: str, to_replace: List[Tuple[str, str]]):
    def read_file(file_path):
        with open(file_path) as f:
            return f.read()
    general_in_text = read_file(general_infile)
    with open(outfile, "w") as f:
        f.write(reduce(lambda s, p: s.replace(p[0], p[1]), [(pattern, read_file(infile)) for pattern, infile in to_replace], general_in_text))

[partial(compile, "setup-general.sh")(*p) for p
 in [[o, [("__PLATFORM_SPECIFIC_VARIABLE_SETUP__", t), ("__PLATFORM_SPECIFIC_PRE_SSH_SETUP__", s)]] for o, t, s in
     [("gcp/setup.sh", "terraform-variable-setup-gcp.sh", "ssh-setup-gcp.sh"),
      ("aws/setup.sh", "terraform-variable-setup-aws.sh", "ssh-setup-aws.sh")]]]
