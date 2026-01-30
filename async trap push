import asyncio
import asyncpg
from datetime import datetime
from trap_processor import clean_trap

class trap_push:

    def __init__(self, db_config: dict):
        self.db_config = db_config
        self.pool = None


    async def connect(self):
        # connect to the database (keeps db connection open)
        self.pool = await asyncpg.create_pool(
            host = self.db_config[''],
            port = self.db_config[''],
            database = self.db_config[''],
            user = self.db_config[''],
            password = self.db_config['']
        )


    async def write_trap(self, trap_data: dict):

        async with self.pool.acquire() as conn:
            await conn.execute
