# README
Setting up your system for development with mtg-draft-service

Update apt:

```bash
sudo apt update
```

Install dependencies for ruby:

```bash
sudo apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev
```

Get rbenv:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
```

```bash
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc
	source ~/.bashrc
```

```bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

Get ruby:

```bash
rbenv install 2.5.1
```

```bash
rbenv global 2.5.1
```

Configure gems and install bundler:

```bash
echo "gem: --no-document" > ~/.gemrc
```

```bash
gem install bundler
```

Install rails:

```bash
gem install rails -v 5.2.0
```

Rehash ruby:

```bash
rbenv rehash
```

Install postgres:

```bash
sudo su -
```

```bash
apt-get install postgresql postgresql-contrib
```

```bash
update-rc.d postgresql enable
```

If you cannot log in to postgres with `su - postgres` update the postgres user password:

```bash
sudo -u postgres psql
```

```sql
ALTER USER postgres PASSWORD 'newpassword';
```

Configuration

Run bundler `bundle install`

Generate key with `rake secret` and set to environment variable DEVISE_JWT_SECRET_KEY

Database initialization

Start postgres with `service postgresql start`

Run `rake db:migrate`

How to run the test suite

`bundle exec rspec spec`

Deployment instructions

TBD
