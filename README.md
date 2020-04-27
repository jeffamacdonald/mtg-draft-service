# README
Setting up your system for development with mtg-draft-service

Update apt:

	* ```sudo apt update```

Install dependencies for ruby:

	* ```sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev```

Get rbenv:

	* ```git clone https://github.com/rbenv/rbenv.git ~/.rbenv```

	* ```echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc```

	* ```echo 'eval "$(rbenv init -)"' >> ~/.bashrc
	source ~/.bashrc```

	* ```git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build```

Get ruby:

	* ```rbenv install 2.5.1```

	* ```rbenv global 2.5.1```

Configure gems and install bundler:

	* ```echo "gem: --no-document" > ~/.gemrc```

	* ```gem install bundler```

Install rails:

	* ```gem install rails -v 5.2.0```

Rehash ruby:

	* ```rbenv rehash```

Install postgres:

	* ```sudo su -```

	* ```apt-get install postgresql postgresql-contrib```

	* ```update-rc.d postgresql enable```

If you cannot log in to postgres with `su - postgres` update the postgres user password:

	* ```sudo -u postgres psql```

	* ```ALTER USER postgres PASSWORD 'newpassword';```

Configuration

	* Run bundler `bundle install`

	* Generate key with `rake secret` and set to environment variable DEVISE_JWT_SECRET_KEY

Database initialization

	* Start postgres with `service postgresql start`

	* Run `rake db:migrate`

How to run the test suite

	* `bundle exec rspec spec`

Deployment instructions

	* TBD
