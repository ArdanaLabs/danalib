{ hci-effects }:
{
  src,
  gitRemote,
  hostKey,
  triggerBranch,
  pushToBranch,
  owner,
  repo,
  branchRoot,
  committerEmail,
  committerName,
  authorName,
  preGitInit ? "",
  ...
}:
hci-effects.runIf (src.ref == "refs/heads/${triggerBranch}") (
  hci-effects.mkEffect {
    src = src;
    buildInputs = with pkgs; [openssh git];
    secretsMap = {
      "ssh" = "ssh";
    };
    effectScript = ''
      writeSSHKey
      echo ${hostKey} >> ~/.ssh/known_hosts
      export GIT_AUTHOR_NAME="${authorName}"
      export GIT_COMMITTER_NAME="${committerName}"
      export EMAIL="${committerEmail}"
      cp -r --no-preserve=mode ${branchRoot} ./${pushToBranch} && cd ${pushToBranch}
      ${preGitInit}
      git init -b ${pushToBranch}
      git remote add origin ${gitRemote}:${owner}/${repo}.git
      git add .
      git commit -m "Deploy to ${pushToBranch}"
      git push -f origin ${pushToBranch}:${pushToBranch}
    '';
  }
)
