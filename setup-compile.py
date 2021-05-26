from functools import reduce, partial
from typing import List, Tuple

# Run this to generate the platform-specific scripts

# to_replace is a list of tuples of the form pattern, infile.
# Reads general_infile; replaces each pattern with the contents of its corresponding infile; writes to outfile
def compile(general_infile: str, outfile: str, to_replace: List[Tuple[str, str]]):
    def read_file(file_path):
        with open(file_path) as f:
            return f.read()
    with open(outfile, "w") as f:
        f.write(reduce(lambda s, p: s.replace(p[0], p[1]),
                       [(pattern, read_file(infile)) for pattern, infile in to_replace],
                       read_file(general_infile)))

[partial(compile, "setup-general.sh")(*p) for p
 in [[o, [("__PLATFORM_SPECIFIC_CLI_SETUP__", c),
          ("__PLATFORM_SPECIFIC_VARIABLE_SETUP__", t),
          ("__PLATFORM_SPECIFIC_PRE_SSH_SETUP__", s),
          ("__PLATFORM_SPECIFIC_DEPLOY__", d)]]
     for o, c, t, s, d in
     [("gcp/setup.sh", "cli-gcp.sh", "terraform-variable-setup-gcp.sh", "ssh-setup-gcp.sh", "deploy-gcp.sh"),
      ("aws/setup.sh", "cli-aws.sh", "terraform-variable-setup-aws.sh", "ssh-setup-aws.sh", "deploy-aws.sh")]]]

[partial(compile, "destroy-admin-server-general.sh")(*p) for p
 in [[o, [("__PLATFORM_SPECIFIC_DESTROY__", d)]]
     for o, d in
     [("gcp/destroy-admin-server.sh", "destroy-gcp.sh"),
      ("aws/destroy-admin-server.sh", "destroy-aws.sh")]]]
