let GithubType
	: Type
	= { fetchMethod :
		  Text
	  , owner :
		  Text
	  , repo :
		  Text
	  , rev :
		  Optional Text
	  , fetchSubmodules :
		  Optional Bool
	  , sha256 :
		  Optional Text
	  }

let Package = < Empty : {} | Github : GithubType >

let transfromGithub
	: GithubType → GithubType
	=   λ ( g
		  : GithubType
		  )
	  →   g
		⫽ { rev =
			  Some
			  ( Optional/fold
				Text
				g.rev
				Text
				(λ(r : Text) → r)
				"\$(nix-prefetch-github --rev master ${g.owner} ${g.repo} | jq -r .rev)"
			  )
		  , sha256 =
			  Some
			  ( Optional/fold
				Text
				g.rev
				Text
				(   λ ( r
					  : Text
					  )
				  → "\$(nix-prefetch-github --rev ${r} ${g.owner} ${g.repo} | jq -r .sha256)"
				)
				"\$(nix-prefetch-github --rev master ${g.owner} ${g.repo} | jq -r .sha256)"
			  )
		  }

let getGithub =
		λ(owner : Text)
	  → λ(repo : Text)
	  → Package.Github
		(   { owner = owner, repo = repo }
		  ⫽ { fetchMethod =
				"fetchFromGitHub"
			, fetchSubmodules =
				None Bool
			, rev =
				None Text
			, sha256 =
				None Text
			}
		)

let transfrom =
		λ(p : Package)
	  → let handlers =
			  { Empty =
				  Package.Empty
			  , Github =
				  λ(g : GithubType) → Package.Github (transfromGithub g)
			  }

		in  merge handlers p : Package

let githubHelper =
		λ(owner : Text)
	  → λ(repo : Text)
	  → { mapKey = repo, mapValue = transfrom (getGithub owner repo) }

in  [ "PLACEHOLDER" ]