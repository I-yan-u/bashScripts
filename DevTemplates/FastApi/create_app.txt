"""
Copyright (c) 12/2024 - iyanuajimobi12@gmail.com
"""

import os
from fastapi import FastAPI
from fastapi.responses import RedirectResponse


def create_app(app_name: str = 'temporary') -> FastAPI:
    """
    The create_app function is the entry point for our application.
    """

    # inject global dependencies
    app = FastAPI(
        title=app_name.capitalize(), # app_configs.APP_NAME.capitalize(),
        description=f'{app_name.capitalize()}`s Api Documentation', # f"{app_configs.APP_NAME.capitalize()}'s Api Documentation",
        docs_url='api/docs', # app_configs.SWAGGER_DOCS_URL,
    )

    @app.get("/", include_in_schema=False)
    def redirect():
        return RedirectResponse(url='api/docs', status_code=302)
    
    return app
