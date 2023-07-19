# Postgres Migrate

This is a simple tool to migrate data from one postgres database to another. It is intended to be used in migrating data from a production database to a development database or in the process of changing database clusters.

## Usage

```bash
$ ./migrate.sh
```

## Configuration

The script will look for a file called `.env` in the same directory as the script. To configure the script, create a file called `.env` and copy the contents of `.env.example` into it. Then, edit the values to match your environment.

Note that the script can also work without a `.env` file, but you will need to pass the required values manually.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.